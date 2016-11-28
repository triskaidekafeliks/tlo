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

function zone_reset
{
  current_zone_index=0
  in_select_map=0
  present_zone=-99
}

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
    else
      t_echo "Could not deduce zone index!"
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
    sq_echo "Opening zone selection"
    xdo_and_return mousemove $CLICK_OPEN_ZONE_SELECT click 1
    return 1
  else
    sq_echo "Already in the destination zone"
    return 0
  fi
}

function start_cadaver
{
  cadaver=$1
  drops_gear=1
  click_location=""
  swipe_start=""
  swipe_end=""
  swipe2_start=""
  swipe2_end=""

  case $cadaver in
    Cook)
      zone_name="Downtown"
      ;;
    Alzheimer)
      zone_name="Downtown"
      ;;
    MissusMechanic)
      zone_name="Downtown"
      ;;
    Firefighter)
      zone_name="Downtown"
      ;;
    Surgeon)
      zone_name="Downtown"
      ;;
    Sheriff)
      zone_name="Downtown"
      ;;
    Electrician)
      zone_name="Industrial"
      ;;
    Concreter)
      zone_name="Industrial"
      ;;

    RoadWorker)
      zone_name="Industrial"
      ;;
    TwinFriend)
      zone_name="Industrial"
      ;;

    Hauler)
      zone_name="Industrial"
      ;;
    Trackwalker)
      zone_name="Industrial"
      ;;

    Farmer)
      zone_name="Suburbs"
      ;;
    Exterminator)
      zone_name="Suburbs"
      ;;

    Defroster)
      zone_name="Suburbs"
      ;;
    DeadBaron)
      zone_name="Suburbs"
      drops_gear=0
      ;;

    Milligans)
      zone_name="Suburbs"
      ;;
    Olympia)
      zone_name="Suburbs"
      ;;

    Avenger)
      zone_name="City"
      drops_gear=0
      ;;
    Archivist)
      zone_name="City"
      ;;

    StewardAbraham)
      zone_name="City"
      ;;
    CoachKen)
      zone_name="City"
      drops_gear=0
      ;;

    Moliere)
      zone_name="City"
      drops_gear=0
      ;;
    Jamshid)
      zone_name="City"
      ;;

    Cleaner)
      zone_name="Megamall"
      drops_gear=0
      ;;
    Radiosaurus)
      zone_name="Megamall"
      ;;

    Miriam)
      zone_name="Megamall"
      drops_gear=0
      ;;
    Slam)
      zone_name="Megamall"
      ;;

    Oscar)
      zone_name="Megamall"
      ;;
    Sentry)
      zone_name="Megamall"
      drops_gear=0
      ;;

    Siphon)
      zone_name="AmusementPark"
      drops_gear=0
      ;;
    Bearhunter)
      zone_name="AmusementPark"
      drops_gear=0
      ;;

    BillyStrongman)
      zone_name="AmusementPark"
      drops_gear=0
      ;;
    Cassandra)
      zone_name="AmusementPark"
      ;;

    GuestPerformer)
      zone_name="AmusementPark"
      ;;
    Momentalist)
      zone_name="AmusementPark"
      ;;

    AuntJulia)
      zone_name="Asylum"
      drops_gear=0
      ;;
    Nurse)
      zone_name="Asylum"
      ;;

    Shepherd)
      zone_name="Asylum"
      ;;
    Paramedics)
      zone_name="Asylum"
      drops_gear=0
      ;;

    Experiment7)
      zone_name="Asylum"
      ;;
    Neurosurgeon)
      zone_name="Asylum"
      ;;

    Balthazar)
      zone_name="Archipelago"
      ;;
    SeaDemon)
      zone_name="Archipelago"
      ;;

    *)
      t_echo "Haven't coordinated cadaver: $1"
      return 1
      ;;
  esac

  if select_zone $zone_name
  then
    swipe_start=$(eval "echo \$${cadaver^^}_SWIPE_START")
    swipe_end=$(eval "echo \$${cadaver^^}_SWIPE_END")
    swipe2_start=$(eval "echo \$${cadaver^^}_SWIPE2_START")
    swipe2_end=$(eval "echo \$${cadaver^^}_SWIPE2_END")
    click_location=$(eval "echo \$${cadaver^^}_LOCATION")
    starting_cadaver=1
    clearwait=0
  fi
}

function goto_downtown_citadel
{
  # If we're already Downtown, go ahead and click the citadel.  Otherwise
  # we'll get called again once the zone-selection is complete.
  if select_zone Downtown
  then
    xdo_and_return mousemove $CLICK_DOWNTOWN_CITADEL click 1
  fi
}

