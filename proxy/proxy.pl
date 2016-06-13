#!/usr/bin/perl -w
use strict;
$ENV{PATH} = join ":", qw(/usr/ucb /bin /usr/bin);
$|++;

use Cwd qw(abs_path);

my $VERSION_ID = q$Id: proxy,v 1.21 1998/xx/xx xx:xx:xx merlyn Exp $;
my $VERSION = (qw$Revision: 1.21 $ )[-1];

## Copyright (c) 1996, 1998 by Randal L. Schwartz
## This program is free software; you can redistribute it
## and/or modify it under the same terms as Perl itself.

### debug management
sub prefix {
  my $now = localtime;

  join "", map { "[$now] [${$}] $_\n" } split /\n/, join "", @_;
}
$SIG{__WARN__} = sub { warn prefix @_ };
$SIG{__DIE__} = sub { die prefix @_ };
&setup_signals();

### logging flags
my $LOG_PROC = 1;               # begin/end of processes
my $LOG_TRAN = 1;               # begin/end of each transaction
my $LOG_REQ_HEAD = 1;           # detailed header of each request
my $LOG_REQ_BODY = 0;           # header and body of each request
my $LOG_RES_HEAD = 1;           # detailed header of each response
my $LOG_RES_BODY = 0;           # header and body of each response
my $LWP_DEBUG = 0;              # set on full LWP Debuging

### configuration
my $HOST = $ARGV[0] || 'kogut';
my $PORT = $ARGV[1] || 8080;    # pick next available user-port
my $SLAVE_COUNT = 8;            # how many slaves to fork
my $MAX_PER_SLAVE = 20;         # how many transactions per slave

my $CERT = abs_path(".")."/certs/cert.pem";
die "cant locate SSL certificate file: $CERT - $!\n" unless -f $CERT;
my $KEY  = abs_path(".")."/certs/key.pem";
die "cant locate SSL key file: $KEY - $!\n" unless -f $KEY;

### main
warn("running version ", $VERSION);
#MyHTTP::Daemon::ClientConn::import(); # force the fixing of the meths
               
&main();
exit 0;

### subs
sub main {                      # return void
  use HTTP::Daemon;
  my %kids;

  my $master = HTTP::Daemon->new(LocalPort => $PORT, LocalAddr => $HOST)
      or die "Cannot create master: $!";
  warn("master is ", $master->url);
  ## fork the right number of children
  for (1..$SLAVE_COUNT) {
    $kids{&fork_a_slave($master)} = "slave";
  }
  {                             # forever:
    my $pid = wait;
    my $was = delete ($kids{$pid}) || "?unknown?";
    warn("child $pid ($was) terminated status $?") if $LOG_PROC;
    if ($was eq "slave") {      # oops, lost a slave
      sleep 1;                  # don't replace it right away (avoid thrash)
      $kids{&fork_a_slave($master)} = "slave";
    }
  } continue { redo };          # semicolon for cperl-mode
}

sub setup_signals {             # return void

  setpgrp;                      # I *am* the leader
  $SIG{HUP} = $SIG{INT} = $SIG{TERM} = sub {
    my $sig = shift;
    $SIG{$sig} = 'IGNORE';
    kill $sig, 0;               # death to all-comers
    die "killed by $sig";
  };
}

sub fork_a_slave {              # return int (pid)
  my $master = shift;           # HTTP::Daemon

  my $pid;
  defined ($pid = fork) or die "Cannot fork: $!";
  &child_does($master) unless $pid;
  $pid;
}

sub child_does {                # return void
  my $master = shift;           # HTTP::Daemon

  my $did = 0;                  # processed count

  warn("child started") if $LOG_PROC;
  {
    flock($master, 2);          # LOCK_EX
    warn("child has lock") if $LOG_TRAN;
    my $slave = $master->accept or die "accept: $!";
    warn("child releasing lock") if $LOG_TRAN;
    flock($master, 8);          # LOCK_UN
    my @start_times = (times, time);
    $slave->autoflush(1);
    warn("connect from ", $slave->peerhost) if $LOG_TRAN;
    &handle_one_connection($slave); # closes $slave at right time
    if ($LOG_TRAN) {
      my @finish_times = (times, time);
      for (@finish_times) {
        $_ -= shift @start_times; # crude, but effective
      }
      warn(sprintf "times: %.2f %.2f %.2f %.2f %d\n", @finish_times);
    }

  } continue { redo if ++$did < $MAX_PER_SLAVE };
  warn("child terminating") if $LOG_PROC;
  exit 0;
}


my $password = "";

sub callback {
  return $password;
}


sub handle_one_connection {     # return void
  use HTTP::Request;
  use IO::Socket::SSL qw(debug4);
  my $handle = shift;           # HTTP::Daemon::ClientConn

  my $request = $handle->get_request;
  defined($request) or die "bad request"; # XXX

  if ( $request->method() =~ /CONNECT/ ){
    my $response = new HTTP::Response;
    $response->protocol("HTTP/1.0");
    $response->code("200");
    $response->message("Connection established");
    $response->header('Proxy-agent' => 'Apache/1.3.x (Unix)');
    $response->request($request);
    $handle->send_response($response);
    my $myurl = $request->url;
    my $s = IO::Socket::SSL::socket_to_SSL($handle,
                                           SSL_server => 1,
                                           SSL_key_file => $KEY,
                                           SSL_cert_file => $CERT,
					   );

    bless($handle, "MyHTTP::Daemon::ClientConn");

    # allow HTTP::Daemon to reprocess
    ${*$handle}{'httpd_nomore'} = undef;
    $request = $handle->get_request(undef, $myurl);
    return unless $request;

    # Client does a reconnect here
    $request->uri($myurl.$request->uri());
  }


  if (my ($req, $q) = $request->uri() =~ /^http:\/\/(.*?)(:443.*?)$/ ){
    $request->uri("https://$req".$q);
  }

  my $response = &fetch_request($request);
  warn "response code:".$response->code()."\n";
  warn "response message:".$response->message()."\n\n\n\n\n";
  warn("response: <<<\n", $response->headers_as_string, "\n>>>")
    if $LOG_RES_HEAD and not $LOG_RES_BODY;
  warn("response: <<<\n", $response->as_string, "\n>>>")
    if $LOG_RES_BODY;
  $handle->send_response($response);
  close $handle;
}

sub fetch_request {             # return HTTP::Response
  use HTTP::Response;
  my $request = shift;          # HTTP::Request

  ## XXXX needs policy here
  my $url = $request->url;

  if ($url->scheme !~ /^(https?|gopher|ftp)$/) {
    warn "problem with request type: ".$url->scheme()."\n";
    my $res = HTTP::Response->new(403, "Forbidden");
    $res->content("bad scheme: @{[$url->scheme]}\n");
    $res;
#  } elsif (not $url->rel("$url")->netloc) {
#  } elsif (not $url->rel("$url")->authority) {
#    my $res = HTTP::Response->new(403, "Forbidden");
#    $res->content("relative URL not permitted\n");
#    $res;
  } else {
    ## validated request, get it!
    warn("processing url is $url") if $LOG_TRAN;
    &fetch_validated_request($request);
  }
}

BEGIN {                         # local static block
  my $agent;                    # LWP::UserAgent

  sub fetch_validated_request { # return HTTP::Response
    my $request = shift;                # HTTP::Request

    $agent ||= do {
      use LWP::UserAgent;

      # enable LWP Debuging
      if ($LWP_DEBUG){
        require LWP::Debug;
        LWP::Debug::level('+');
      }
      my $agent = LWP::UserAgent->new;
      $agent->agent("proxy/$VERSION " . $agent->agent);
      $agent->env_proxy;
      $agent;
    };
    
    warn("fetch: <<<\n", $request->headers_as_string, "\n>>>")
      if $LOG_REQ_HEAD and not $LOG_REQ_BODY;
    warn("fetch: <<<\n", $request->as_string, "\n>>>")
      if $LOG_REQ_BODY;

    my $response = $agent->simple_request($request);

    if ($response->is_success and
        $response->content_type =~ /text\/(plain|html)/ and
        not ($response->content_encoding || "") =~ /\S/ and
        ($request->header("accept-encoding") || "") =~ /gzip/) {
      require Compress::Zlib;
      my $content = $response->content;
      my $new_content = Compress::Zlib::memGzip($content);
      if (defined $new_content) {
        $response->content($new_content);
        $response->content_length(length $new_content);
        $response->content_encoding("gzip");
        warn("gzipping content from ".
             (length $content)." to ".
             (length $new_content)) if $LOG_TRAN;
      }
    }

    $response;
  }
}


# Alternative connection object for SSL
package MyHTTP::Daemon::ClientConn;
use base qw(IO::Socket::SSL);
use vars qw($DEBUG);
*DEBUG = \$HTTP::Daemon::DEBUG;

use HTTP::Request  ();
use HTTP::Response ();
use HTTP::Status;
use HTTP::Date qw(time2str);
use LWP::MediaTypes qw(guess_media_type);
use Carp ();

my $CRLF = "\015\012";   # "\r\n" is not portable
my $HTTP_1_0 = _http_version("HTTP/1.0");
my $HTTP_1_1 = _http_version("HTTP/1.1");

#  This is a kind of psuedo inheritence 
#  I wanted to inherit from HTTP::Daemon::ClientConn
#  but I wanted it to inherit from IO::Socket::SSL
use vars qw($AUTOLOAD);
my $caller = __PACKAGE__;

sub AUTOLOAD {
  $AUTOLOAD =~ s/^.*:://;
  no strict 'refs';
  # make sure the subroutine exists to alias
  if ( *{"HTTP::Daemon::ClientConn::${AUTOLOAD}"}{CODE} ){
  *{"${caller}::${AUTOLOAD}"} = \&{"HTTP::Daemon::ClientConn::${AUTOLOAD}"};
  goto &{"${caller}::${AUTOLOAD}"};
  } else {
    die "HTTP::Daemon::ClientConn does not contain ${AUTOLOAD} as a subroutine\n";
  }
}

1;


