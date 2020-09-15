# Import-Synology-SSL-to-Emby
This is a simple bash script to copy the current default SSL certifcate from Synology over to an emby server running on the same box

## Steps to setup
1)  Download shell script and place in a secure location (script will be run as root so you do not want just any user to be able to edit the file)
2)  Create a new task (cronjob) on the synology nas (Control Panel -> Task Scheduler)
    ![alt text](./images/task-General.png?raw=true "")
    ![alt text](./images/task-Schedule.png?raw=true "")
    ![alt text](./images/task-Task_Settings.png?raw=true "")
3)  Edit Emby Network settings to use the certificate
    ![alt text](./images/emby-Network_Settings.png?raw=true "")