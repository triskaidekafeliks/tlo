#!/bin/bash

interrupt_actions=()

#interrupt_actions+=('
#  condition="test_game_contents free_gifts.png $TEST_FREE_GIFTS"
#  message="Gifting grenades"
#  action="xdo_and_return mousemove $CLICK_SELECT_GRENADES click 1"
#')
#interrupt_actions+=('
#  condition="test_game_contents send_gift.png $TEST_SEND_GIFT"
#  message="Sending the gifts"
#  action="xdo_and_return mousemove $CLICK_SEND_GIFTS click 1"
#')
interrupt_actions+=('
  condition="test_game_contents free_gifts.png $TEST_FREE_GIFTS"
  message="Skipping gifting"
  action="xdo_and_return mousemove $CLICK_CLOSE_GIFTING click 1"
')

# A cadaver fight finished.  Need to check for this in addition to the
# check above, in case we left a cadaver fight to join MC, and it was
# finished in absentia while we wait on the Join-MC dialog - otherwise
# that would get obscured.
interrupt_actions+=('
  condition="test_game_contents cadaver_closure.png $TEST_CADAVER_VICTORY1 ||
             test_game_contents cadaver_closure.png $TEST_CADAVER_VICTORY2 ||
             test_game_contents citadel_cadaver_closure.png $TEST_CITADEL_CLOSURE ||
             test_game_contents cadaver_start_battle.png $TEST_CADAVER_STARTNEW"
  message="Detected completed cadaver battle"
  action="xdo_and_return mousemove $CLICK_ATTACK_BOSS click 1"
')

interrupt_actions+=('
  condition="test_game_contents mc_finished_X.png $TEST_MC_FINISHED_WIN"
  message="Finished MC \\(win\\)"
  action="xdo_and_return mousemove $CLICK_MC_FINISHED_WIN click 1"
')

interrupt_actions+=('
  condition="test_game_contents mc_finished_X.png $TEST_MC_FINISHED_DEFEAT"
  message="Finished MC \\(defeat\\)"
  action="xdo_and_return mousemove $CLICK_MC_FINISHED_DEFEAT click 1"
')

interrupt_actions+=('
  condition="test_game_contents weapon_repair.png $TEST_WEAPON_BROKEN"
  message="Repairing weapon"
  action="xdo_and_return mousemove $CLICK_REPAIR_WEAPON click 1"
')

interrupt_actions+=('
  condition="test_game_contents citadel_premium_start.png $TEST_CITADEL_PREMIUM"
  message="Dismiss premium citadel start"
  action="xdo_and_return mousemove $CLICK_LEAVE_CITADEL click 1"
')

interrupt_actions+=('
  condition="test_game_contents no_gifts.png $TEST_NO_GIFTS"
  message="Dismiss no gifts dialog..."
  action="xdo_and_return mousemove $CLICK_DISMISS_NO_GIFTS click 1"
')

interrupt_actions+=('
  condition="test_game_contents phone_close.png $TEST_MOBILE_PHONE 0.01"
  message="Dismiss mobile phone..."
  action="xdo_and_return mousemove $CLICK_DISMISS_PHONE click 1"
')

interrupt_actions+=('
  condition="test_game_contents killed_by_cadaver.png $TEST_YOU_DIED"
  message="Dismiss \"You died\" dialog..."
  action="xdo_and_return mousemove $CLICK_DISMISS_DEATH click 1"
')
 
interrupt_actions+=('
  condition="test_game_contents help_others.png $TEST_HELP_OTHERS"
  message="Helping other players"
  action="xdo_and_return mousemove $CLICK_HELP_OTHERS click 1"
')

interrupt_actions+=('
  condition="test_game_contents strongbox_no_recips.png $TEST_STRONGBOX_TO_NOONE"
  message="Restart after duff strongbox popup"
  action="refresh_game"
')

interrupt_actions+=('
  condition="test_game_contents social_network_failure.png $TEST_SOCIAL_NETWORK_FAILURE"
  message="Restart after social network failure"
  action="refresh_game"
')

interrupt_actions+=('
  condition="test_game_contents connection_cocked_up.png $TEST_CONNECTION_FUBAR"
  message="Restart after connection outage"
  action="refresh_game"
')

#interrupt_actions+=('
#  condition="test_game_contents send_golden_strongbox.png $TEST_SEND_STRONGBOX"
#  message="Sending golden strongboxes"
#  action="xdo_and_return mousemove $CLICK_SEND_STRONGBOX click 1"
#')
interrupt_actions+=('
  condition="test_game_contents send_golden_strongbox.png $TEST_SEND_STRONGBOX"
  message="Not sending golden strongboxes"
  action="xdo_and_return mousemove $CLICK_CLOSE_STRONGBOX click 1"
')

interrupt_actions+=('
  condition="test_game_contents help_friends.png $TEST_HELP_FRIENDS"
  message="Not helping friends automatically"
  action="xdo_and_return mousemove $CLICK_DISMISS_HELP_FRIENDS click 1"
')

interrupt_actions+=('
  condition="test_game_contents send_requests.png $TEST_SEND_FB_REQUESTS"
  message="Sending FB requests"
  action="xdo_and_return mousemove $CLICK_SEND_FB_REQUESTS click 1"
')

interrupt_actions+=('
  condition="test_game_contents take_rewards.png $TEST_MISSION_REWARDS"
  message="Accepting mission rewards"
  action="xdo_and_return mousemove $CLICK_MISSION_REWARDS click 1"
')

interrupt_actions+=('
  condition="test_game_contents new_level.png $TEST_NEW_LEVEL"
  message="Went up a level, yay!"
  action="xdo_and_return mousemove $CLICK_NEW_LEVEL click 1"
')

interrupt_actions+=('
  condition="test_game_contents drone_level_up.png $TEST_DRONE_LEVEL_UP"
  message="Drone went up a level, yay!"
  action="xdo_and_return mousemove $CLICK_DRONE_LEVELLED click 1"
')

interrupt_actions+=('
  condition="test_game_contents survivors_diary.png $TEST_DAILY_MISSIONS"
  message="Closing daily missions"
  action="xdo_and_return mousemove $CLICK_CLOSE_DAILIES click 1"
')

# Sometimes the script manages to click somewhere it shouldn't, such as...

# A location for clearing
interrupt_actions+=('
  condition="test_game_contents photo_pieces_found.png $TEST_PHOTO_PIECES_FOUND"
  message="Clearing accidental location dialog..."
  action="xdo_and_return mousemove $CLICK_DISMISS_LOCATION click 1"
')

# A business
# Not fully rebuilt - rebuild button
interrupt_actions+=('
  condition="test_game_contents rebuild_business_button.png $TEST_REBUILD_BUTTON"
  message="Dismissing growing business"
  action="xdo_and_return mousemove $CLICK_DISMISS_BUSINESS click 1"
')

#Fully built - resource exchange notice
interrupt_actions+=('
  condition="test_game_contents resource_exchange.png $TEST_RESOURCE_EXCHANGE"
  message="Dismissing full-grown business"
  action="xdo_and_return mousemove $CLICK_DISMISS_BUSINESS click 1"
')

# Arena combat (wrong league)
interrupt_actions+=('
  condition="test_game_contents to_your_league.png $TEST_GOTO_LEAGUE"
  message="Clearing accidental arena dialog..."
  action="xdo_and_return mousemove $CLICK_DISMISS_ARENA click 1"
')

# Arena combat (correct league)
interrupt_actions+=('
  condition="test_game_contents arena_battle_button.png $TEST_ARENA_BATTLE"
  message="Clearing \\(correct\\) accidental arena dialog..."
  action="xdo_and_return mousemove $CLICK_DISMISS_ARENA click 1"
')

# Devastator
interrupt_actions+=('
  condition="test_game_contents devastator.png $TEST_DEVASTATOR"
  message="Dismissing Devastator..."
  action="xdo_and_return mousemove $CLICK_DISMISS_DEVASTATOR click 1"
')

interrupt_actions+=('
  condition="test_game_contents shop_help.png $TEST_SHOP"
  message="Dismissing store..."
  action="xdo_and_return mousemove $CLICK_CLOSE_SHOP click 1"
')

interrupt_actions+=('
  condition="test_game_contents new_items.png $TEST_NEW_ITEMS"
  message="Accepting new items..."
  action="xdo_and_return mousemove $CLICK_ACCEPT_NEW_ITEMS click 1"
')

interrupt_actions+=('
  condition="test_game_contents special_offer_closure.png $TEST_SPECIAL_OFFER 0.01"
  message="Dismissing special offer dialog..."
  action="xdo_and_return mousemove $CLICK_CLOSE_SPECIAL_OFFER click 1"
')

# Mission details dialog (different coordinates for one/two objectives)
interrupt_actions+=('
  condition="test_game_contents mission_continue_button.png $TEST_MISSION_DETAILS"
  message="Clearing mission details..."
  action="xdo_and_return mousemove $CLICK_MISSION_CONTINUE click 1"
')
interrupt_actions+=('
  condition="test_game_contents mission_continue_button.png $TEST_MISSION_DETAILS_TWO"
  message="Clearing mission details for two requirements..."
  action="xdo_and_return mousemove $CLICK_MISSION_CONTINUE_TWO click 1"
')

interrupt_actions+=('
  condition="test_game_contents rebuild_base.png $TEST_REBUILD_BASE ||
             test_game_contents level_required.png $TEST_REBUILD_LEVEL_REQ"
  message="Dismissing base rebuild dialog..."
  action="xdo_and_return mousemove $CLICK_CLOSE_BASE_REBUILD click 1"
')

# First click after down keys is to close the news page, but there might be a gold
# sale, so second click gets rid of that - then we need to actually close
# the news page!
interrupt_actions+=('
  condition="test_game_contents flash_crash.png $TEST_FLASH_CRASH"
  message="Flash crashed!  Reloading..."
  finalaction=1
  action="
    xdo_and_return mousemove $CLICK_FLASH_CRASH_RELOAD click 1 sleep 0.1;
    sleep 60
"')

interrupt_actions+=('
  condition="test_game_contents fb_header.png $TEST_FB_HEADER"
  sqmessage="Do first adjustment scroll..."
  action="xdo_and_return mousemove $CLICK_RIGHT_OF_GAME_AREA click 5"
')

interrupt_actions+=('
  condition="test_game_contents like_the_game.png $TEST_LIKE_THE_GAME"
  sqmessage="Do second adjustment scroll..."
  action="xdo_and_return mousemove $CLICK_RIGHT_OF_GAME_AREA click 5"
')

interrupt_actions+=('
  condition="test_game_contents connection_lost.png $TEST_CONNECTION_LOST"
  message="Connection lost..."
  action="xdo_and_return mousemove $CLICK_ACCEPT_REFRESH click 1"
')

interrupt_actions+=('
  condition="test_game_contents missing_social_fun.png $TEST_MISSING_SOCIAL_FUN"
  message="Dismiss missing fun reminder..."
  action="xdo_and_return mousemove $CLICK_MISS_FUN click 1"
')

interrupt_actions+=('
  condition="test_game_contents cadaver_already_defeated.png $TEST_CADAVER_ALREADY_DEFEATED"
  message="Cadaver already defeated, oh well"
  action="xdo_and_return mousemove $CLICK_CADAVER_ALREADY_DEFEATED click 1"
')

interrupt_actions+=('
  condition="test_game_contents no_opponents.png $TEST_NO_OPPONENTS"
  message="Found no opponents, boohoo"
  action="xdo_and_return mousemove $CLICK_DISMISS_NO_OPPONENTS click 1"
')

function refresh_game
{
  xdo_and_return mousemove $CLICK_RIGHT_OF_GAME_AREA click 1 key ctrl+F5
  sleep 20
  xdo_and_return mousemove $CLICK_RIGHT_OF_GAME_AREA click 1 sleep 0.1 click 5 click 5
  zone_reset
}
