echo -en "\033]0;Cyber Recovery Component Catalog\a"
string=$2
final=${string//[&]/__}
pwsh -NoExit ./main.ps1 -TestInput1 $1 -TestInput2 $final