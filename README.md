My Blog: http://kevinmarquette.blogspot.com/

This is my first git repo. Using it as a place to store various script and modules that I create in my free time.


DSC Resource KevMar_TcpPrinter

DSC Resource KevMar_MapPrinter

DSC Resource KevMar_WindowsUpdate

Changes in v1.0.2
  Added DriverInf property
    Allows you to provide the location to the driver's inf file to be used during printer installation
  Modified Ensure="Absent"
    Will remove the printer port if the removed printer was the last one using it
    Will remove the driver only if the DriverInf is defined and the removed printer was the last one using it




Modules should be copied into c:\program files\WindowsPowershell
.\Make.ps1 does this on my machine

Notes to self:

git pull


git status
git diff

git add -A

git commit -m -a "Commit message"

git push

http://git-scm.com/book/en/Git-Branching-Basic-Branching-and-Merging
