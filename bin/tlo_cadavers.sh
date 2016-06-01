#!/bin/bash

source screen_scripting_utils.sh
source runactionset.sh
source tlo_common.sh
source tlo_common_actionsets.sh

drops_gear=1
current_zone_index=0
select_zone_actions=()
start_battle_actions=()
in_select_map=0
present_zone=-99

# Initiate the desired cadaver fight (adjust here for new cadavers)

function deduce_zone_index
{
  if test_screen_contents select_map.png $TEST_SELECT_MAP
  then
    in_select_map=1
    if test_game_contents select_map_downtown.png $TEST_LEFT_ZONE_INDICATOR
    then
      current_zone_index=0
    elif test_game_contents select_map_industrial.png $TEST_LEFT_ZONE_INDICATOR
    then
      current_zone_index=1
    elif test_game_contents select_map_suburbs.png $TEST_LEFT_ZONE_INDICATOR
    then
      current_zone_index=2
    elif test_game_contents select_map_city.png $TEST_LEFT_ZONE_INDICATOR
    then
      current_zone_index=3
    elif test_game_contents select_map_megamall.png $TEST_LEFT_ZONE_INDICATOR
    then
      current_zone_index=4
    elif test_game_contents select_map_amusement_park.png $TEST_LEFT_ZONE_INDICATOR
    then
      current_zone_index=5
    elif test_game_contents select_map_asylum.png $TEST_LEFT_ZONE_INDICATOR
    then
      current_zone_index=6
    elif test_game_contents select_map_archipelago.png $TEST_LEFT_ZONE_INDICATOR
    then
      current_zone_index=7
    elif test_game_contents select_map_underground.png $TEST_LEFT_ZONE_INDICATOR
    then
      current_zone_index=8
    elif test_game_contents select_map_descent.png $TEST_LEFT_ZONE_INDICATOR
    then
      current_zone_index=9
    elif test_game_contents select_map_utopia.png $TEST_LEFT_ZONE_INDICATOR
    then
      current_zone_index=10
    elif test_game_contents select_map_glacier.png $TEST_LEFT_ZONE_INDICATOR
    then
      current_zone_index=11
    elif test_game_contents select_map_battlefield.png $TEST_LEFT_ZONE_INDICATOR
    then
      current_zone_index=12
  # This comes into play only if new zones are added; otherwise the wasteland cannot appear in the left position
  #  elif test_game_contents select_map_wasteland.png $TEST_LEFT_ZONE_INDICATOR
  #  then
  #    current_zone_index=13
#    else
#      t_echo "Could not deduce zone index!"
    fi
  else
#    t_echo "Not in select map view"
    in_select_map=0
    current_zone_index=-99
  fi
#t_echo "current_zone_index -> $current_zone_index"
}

function select_zone
{
  sq_echo Going to zone: $1

  select_zone_actions=()

  case $1 in
    Downtown)
      destination_index=0
      ;;
    Industrial)
      destination_index=1
      ;;
    Suburbs)
      destination_index=2
      ;;
    City)
      destination_index=3
      ;;
    Megamall)
      destination_index=4
      ;;
    AmusementPark)
      destination_index=5
      ;;
    Asylum)
      destination_index=6
      ;;
    Archipelago)
      destination_index=7
      ;;
    Underground)
      destination_index=8
      ;;
    Descent)
      destination_index=9
      ;;
    Utopia)
      destination_index=10
      ;;
    Glacier)
      destination_index=11
      ;;
    Battlefield)
      destination_index=12
      ;;
    Wasteland)
      destination_index=13
      ;;
    *)
      t_echo "Unrecognized zone name: $1"
      destination_index=0
      ;;
  esac

#t_echo "destination_index -> $destination_index"

  if (($present_zone != $destination_index))
  then
    select_zone_actions+=('
      condition="! ((\$in_select_map))"
      sqmessage="Opening zone selection"
      action="xdo_and_return mousemove $CLICK_OPEN_ZONE_SELECT click 1"
    ')

    # Shifting actions have an extra short sleep, to minimise the risk of over-shifting
    select_zone_actions+=('
      condition="((\$in_select_map)) && ((\$current_zone_index > $destination_index))"
      sqmessage="Shifting left"
      action="xdo_and_return mousemove $CLICK_ZONES_LEFT_SHIFT click 1 sleep 1"
      repeattoclear=1
    ')

    select_zone_actions+=('
      condition="((\$in_select_map)) && ((\$current_zone_index < $destination_index - 1))"
      sqmessage="Shifting right"
      action="xdo_and_return mousemove $CLICK_ZONES_RIGHT_SHIFT click 1 sleep 1"
      repeattoclear=1
    ')

    select_zone_actions+=('
      condition="((\$in_select_map)) && ((\$current_zone_index == $destination_index))"
      sqmessage="Selecting left"
      action="xdo_and_return mousemove $CLICK_ZONES_LEFT_SELECT click 1"
      finalaction=1
    ')

    select_zone_actions+=('
      condition="((\$in_select_map)) && ((\$current_zone_index == $destination_index - 1))"
      sqmessage="Selecting right"
      action="xdo_and_return mousemove $CLICK_ZONES_RIGHT_SELECT click 1"
      finalaction=1
    ')

    select_zone_actions+=("${interrupt_actions[@]}")

    run_actions select_zone_actions[@] deduce_zone_index
    present_zone=$destination_index
  else
    sq_echo "Already in the destination zone"
  fi
}

function start_cadaver
{
  cadaver=$1
  drops_gear=1
  click_location=""
  swipe_start=""
  swipe_end=""

  case $cadaver in
    Cook)
      select_zone Downtown
      ;;
    Alzheimer)
      select_zone Downtown
      ;;
    MissusMechanic)
      select_zone Downtown
      ;;
    Firefighter)
      select_zone Downtown
      ;;
    Surgeon)
      select_zone Downtown
      ;;
    Sheriff)
      select_zone Downtown
      ;;
    Electrician)
      select_zone Industrial
      ;;
    Concreter)
      select_zone Industrial
      ;;

    RoadWorker)
      select_zone Industrial
      ;;
    TwinFriend)
      select_zone Industrial
      ;;

    Hauler)
      select_zone Industrial
      ;;
    Trackwalker)
      select_zone Industrial
      ;;

    Farmer)
      select_zone Suburbs
      ;;
    Exterminator)
      select_zone Suburbs
      ;;

    Defroster)
      select_zone Suburbs
      ;;
    DeadBaron)
      select_zone Suburbs
      drops_gear=0
      ;;

    Milligans)
      select_zone Suburbs
      ;;
    Olympia)
      select_zone Suburbs
      ;;

    Avenger)
      select_zone City
      drops_gear=0
      ;;
    Archivist)
      select_zone City
      ;;

    StewardAbraham)
      select_zone City
      ;;
    CoachKen)
      select_zone City
      drops_gear=0
      ;;

    Moliere)
      select_zone City
      drops_gear=0
      ;;
    Jamshid)
      select_zone City
      ;;

    Cleaner)
      select_zone Megamall
      drops_gear=0
      ;;
    Radiosaurus)
      select_zone Megamall
      ;;
    Miriam)
      select_zone Megamall
      drops_gear=0
      ;;
    Slam)
      select_zone Megamall
      ;;

    Oscar)
      select_zone Megamall
      ;;
    Sentry)
      select_zone Megamall
      drops_gear=0
      ;;

    Siphon)
      select_zone AmusementPark
      drops_gear=0
      ;;
    Bearhunter)
      select_zone AmusementPark
      drops_gear=0
      ;;

    BillyStrongman)
      select_zone AmusementPark
      drops_gear=0
      ;;
    Cassandra)
      select_zone AmusementPark
      ;;

    GuestPerformer)
      select_zone AmusementPark
      ;;
    Momentalist)
      select_zone AmusementPark
      ;;

    AuntJulia)
      select_zone Asylum
      drops_gear=0
      ;;
    Nurse)
      select_zone Asylum
      ;;

    Unknown_86_1)
      select_zone Asylum
      ;;
    Unknown_86_2)
      select_zone Asylum
      ;;

    Unknown_90_1)
      select_zone Asylum
      ;;
    Unknown_90_2)
      select_zone Asylum
      ;;

    *)
      t_echo "Haven't coordinated cadaver: $1"
      return 1
      ;;
  esac

  swipe_start=$(eval "echo \$${cadaver^^}_SWIPE_START")
  swipe_end=$(eval "echo \$${cadaver^^}_SWIPE_END")
  click_location=$(eval "echo \$${cadaver^^}_LOCATION")

  battle_actions=()

  if [ -n "$swipe_start" ]
  then
    battle_actions+=('
      condition="test_game_contents home_flag.png $TEST_HOME_CENTRED ||
                 test_game_contents home_flag_shrouded.png $TEST_HOME_CENTRED"
      sqmessage="Bringing cadaver location into view"
      action="xdo_and_return mousemove $swipe_start mousedown 1 mousemove $swipe_end mouseup 1"
    ')
  fi

  # 
  battle_actions+=('
    condition="test_game_contents outofmission_check.png $TEST_OUT_OF_MISSION"
    sqmessage="Clicking cadaver location"
    action="xdo_and_return mousemove $click_location click 1"
  ')

  if [ "$drops_gear" == "1" ]
  then
    battle_actions+=('
      condition="test_game_contents cadaver_attack.png $TEST_CADAVER_ATTACK_GEARDROP"
      sqmessage="Attacking with gear"
      action="xdo_and_return mousemove $CLICK_CADAVER_ATTACK_GEARDROP click 1"
    ')
  else
    battle_actions+=('
      condition="test_game_contents cadaver_attack_small.png $TEST_CADAVER_ATTACK_NOGEAR"
      sqmessage="Attacking with gear"
      action="xdo_and_return mousemove $CLICK_CADAVER_ATTACK_NOGEAR click 1"
    ')
  fi

  battle_actions+=('
    condition="test_game_contents cadaver_start_battle.png $TEST_CADAVER_STARTNEW"
    sqmessage="Starting cadaver battle"
    action="xdo_and_return mousemove $CLICK_CADAVER_START_NEW click 1"
    finalaction=1
  ')

  battle_actions+=("${interrupt_actions[@]}")

  run_actions battle_actions[@] true
}

