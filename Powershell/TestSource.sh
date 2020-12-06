#!/usr/bin/env bash


#
#


"""

"""
#RUN ME:




function pause(){
 read -s -n 1 -p "Press any key to continue . . ."
 echo ""
}

#I found that Bob Copeland solution http://bobcopeland.com/blog/2012/10/goto-in-bash/ elegant:
function jumpto
{
    label=$1
    cmd=$(sed -n "/$label:/{:a;n;p;ba};" $0 | grep -v ':$')
    eval "$cmd"
    exit
}

activate () {
  source "$(pwd)/env3/bin/activate"
  #source venv37/bin/activate
}

deactivate () {
  deactivate
}

AddPyPath () {
  export PYTHONPATH=$PYTHONPATH:`pwd`:`pwd`/slim
  set PYTHONPATH=.\SRC\Models_src\models
  set PYTHONPATH=.\SRC\Models_src\models\research
  set PYTHONPATH=.\SRC\Models_src\\models\research\slim
}
start=${1:-"start"}


echo "Starting Testing Script"
echo $(pwd)



start:
activate
clear
echo $(pwd)

cd ../..
#sleep 2


#pause
#deactivate


#jumpto $start
