#!/bin/bash
# Anubhav's assignment1 script file
# Author: Anubhav Khanna
# UPI: akha394
# UoA ID: 906412388

# The "CREATIONS_DIRECTORY" constant is being initialized.
CREATIONS_DIRECTORY="./Creations"

print_menu()
{
  echo "=============================================================="
  echo "Welcome to the Wiki-Speak Authoring Tool"
  echo "=============================================================="
  echo "Please select from one of the following options:"
  echo ""
  echo "(l)ist existing creations"
  echo "(p)lay an existing creation"
  echo "(d)elete an existing creation"
  echo "(c)reate a new creation"
  echo "(q)uit authoring tool"
  echo ""
  read -p  "Enter a selection from [l/p/d/c/q] : " menu_input
}

invalid_creation_name_check()
{
  # This method checks if the given creation name is empty or already in use.
  # If so, then it prompts the user to enter another name until the user enters a valid name

  eval creation_name_to_process="\$$1"
  creation_variable_passed_as_argument="$1"
  # The following while loop ensures that the user is continuously asked for an input name as long as a file by the input name already
  # exists or the input is empty
  while [ -e "./Creations/$creation_name_to_process.mp4" ] || [ "$creation_name_to_process" == "" ]
  do
    if [ "$creation_name_to_process" == "" ]
    then
      read -p "The file name cannot be empty. Please enter a name : " creation_name_to_process
      eval $creation_variable_passed_as_argument=$creation_name_to_process
    elif [ -e "./Creations/$creation_name_to_process.mp4" ]
    then
      read -p "A file by the name \"$creation_name_to_process\" already exists. Please enter a different name : " creation_name_to_process
      eval $creation_variable_passed_as_argument=$creation_name_to_process
    fi
  done
}

list_creations()
{
  if [ -d "$CREATIONS_DIRECTORY" ]
  then
    creations_count=`ls $CREATIONS_DIRECTORY -1 | grep .mp4 | wc -l`
    if [ $creations_count != 0 ]
    then
      echo "--------------------------------"
      echo "The creations are as follows : "
      ls $CREATIONS_DIRECTORY -1 | grep .mp4 | sed 's/.mp4//' | sort | cat -n
      ls $CREATIONS_DIRECTORY -1 | grep .mp4 | sed 's/.mp4//' | sort 1> ./Wiki_tool_files/Temporary_creations_list.txt 2> /dev/null
      echo "--------------------------------"
      creations_found=1 # Giving the "creations_found" a value other than 0.
    else
      creations_found=0
      echo -n "There are no creations. "
    fi
  else
    creations_found=0
    echo -n "There are no creations. "
  fi
}

play_creations()
{
  list_creations
  if [ $creations_found == 1 ] # The value of "creations_found" is set in the "list_creations" function
  then
    read -p "Enter the number of the creation you want to play (between 1 and $creations_count): " number_of_creation_to_play
    # The following while loop ensures that the user is continuously asked for an input number until a valid number is entered
    while [[ $number_of_creation_to_play != [0-9]* ]] || [ $number_of_creation_to_play -lt 1 ] || [ $number_of_creation_to_play -gt $creations_count ]
    do
      read -p "Invalid input. Please enter a number between 1 and $creations_count : " number_of_creation_to_play
    done
    # The next line is extracting the name of the creation file to be played, from the Temporary_creations_list.txt file, based on the creation number entered by the user
    creation_to_play=`sed -n $number_of_creation_to_play\p ./Wiki_tool_files/Temporary_creations_list.txt`
    echo "The creation file \"$creation_to_play\" is being played..."
    ffplay -autoexit ./Creations/"$creation_to_play.mp4" &> /dev/null
  else
    read -p "Enter any key to continue" garbage_press
  fi
}

delete_creations()
{
  list_creations
  if [ $creations_found == 1 ] # The value of "creations_found" is set in the "list_creations" function
  then
    read -p "Enter the number of the creation you want to delete (between 1 and $creations_count): " number_of_creation_to_delete
    # The following while loop ensures that the user is continuously asked for an input number until a valid number is entered
    while [[ $number_of_creation_to_delete != [0-9]* ]] || [ $number_of_creation_to_delete -lt 1 ] || [ $number_of_creation_to_delete -gt $creations_count ]
    do
      read -p "Invalid input. Please enter a number between 1 and $creations_count : " number_of_creation_to_delete
    done
    # The next line is extracting the name of the creation file to be deleted, from the Temporary_creations_list.txt file, based on the creation number entered by the user
    creation_to_delete=`sed -n $number_of_creation_to_delete\p ./Wiki_tool_files/Temporary_creations_list.txt`
    read -p "Are you sure you want to delete the file \"$creation_to_delete\"? Press 'y' to confirm or press any other key to not delete the file : " should_file_be_deleted
    if [[ "$should_file_be_deleted" == [yY] ]]
    then
      rm ./Creations/"$creation_to_delete.mp4"
      read -p "The file \"$creation_to_delete\" has been successfully deleted. Enter any key to continue" garbage_press
    else
      read -p "The file \"$creation_to_delete\" was not deleted. Enter any key to show the main menu" garbage_press
    fi
  else
    read -p "Enter any key to continue" garbage_press
  fi
}

create_creations()
{
  # Making the required directories if they are not already present
  mkdir ./Wiki_tool_files &> /dev/null
  mkdir ./Creations &> /dev/null

  should_search_be_repeated="" # This variable is initialized so that the following while loop can be entered for the first time
  while [ "$should_search_be_repeated" != "q" ] && [ "$should_search_be_repeated" != "Q" ]
  do
    read -p "Enter the word you want to search for : " search_word
    # The following line detects if the searched word was not found. The "word_not_found_counter" will be 1 when the word is not found.
    word_not_found_counter=$(wikit $search_word | grep "$search_word not found" | wc -l)
    if [ "$word_not_found_counter" != 1 ]
    then

      # Searching for an existing word asking the user for the number of sentences to include in the creation.
      wikit $search_word | sed 's/\([.!?]\) \([[:upper:]]\)/\1\n\2/g' | sed 's/  //g' > ./Wiki_tool_files/Wiki_sentences.txt
      total_sentences=`cat ./Wiki_tool_files/Wiki_sentences.txt | wc -l`
      cat -n ./Wiki_tool_files/Wiki_sentences.txt
      read -p "How many sentences do you want in the creation? (Between 1 and $total_sentences): " no_of_sentences_to_include
      while [[ $no_of_sentences_to_include != [0-9]* ]] || [ $no_of_sentences_to_include -lt 1 ] || [ $no_of_sentences_to_include -gt $total_sentences ]
      do
        read -p "Invalid input. Please enter a number between 1 and $total_sentences : " no_of_sentences_to_include
      done

      # Generating the audio file for the selected sentences and asking the user for a name for the creation
      sed -n 1,$no_of_sentences_to_include\p ./Wiki_tool_files/Wiki_sentences.txt > ./Wiki_tool_files/Selected_sentences.txt
      espeak -f ./Wiki_tool_files/Selected_sentences.txt -w ./Wiki_tool_files/Wiki_audio.wav
      audio_length=`soxi -D ./Wiki_tool_files/Wiki_audio.wav`
      video_length=$(echo "$audio_length+1.5" | bc)
      read -p "Enter a name for the creation : " "creation_name"
      invalid_creation_name_check "creation_name"

      # Generating the video file for the creation and combining the audio and video files to make the final creation
      ffmpeg -y -f lavfi -i color=c=blue:s=720x480:d=$video_length -vf "drawtext=fontfile=/path/to/font.ttf:fontsize=40: fontcolor=white:x=(w-text_w)/2:y=(h-text_h)/2:text=$search_word" \./Wiki_tool_files/Wiki_video.mp4 &> /dev/null #-y for forcing to overwrite the existing file
      ffmpeg -i ./Wiki_tool_files/Wiki_video.mp4 -i ./Wiki_tool_files/Wiki_audio.wav -c:v copy -c:a aac -strict experimental ./Creations/"$creation_name.mp4" &> /dev/null
      should_search_be_repeated="q" # Making sure that the user is not asked for another word if the word searched for was valid
      read -p "A creation with the name \"$creation_name\" was successfully created. Enter any key to continue" garbage_press
    else
      read -p "This word does not exist. Enter (q) to exit back to the main menu or press any other key to be asked for another word : " should_search_be_repeated
    fi
  done
}

menu_input="" # The variable "menu_input" is being initialized so that the main while loop can be entered for the first time
# Following is the main while loop of this script
while [[ $menu_input != [qQ] ]]
do
  print_menu
  if [[ $menu_input == [lL] ]]
  then
    list_creations
    read -p "Enter any key to continue" garbage_press
  elif [[ $menu_input == [pP] ]]
  then
    play_creations
  elif [[ "$menu_input" == [dD] ]]
  then
    delete_creations
  elif [[ "$menu_input" == [cC] ]]
  then
    create_creations
  elif [[ "$menu_input" == [qQ] ]]
  then
    exit 0
  else
    read -p "Please enter one option from (l, p, d, c, q) when the menu appears again. Enter any key to show the menu" garbage_press
  fi
done
