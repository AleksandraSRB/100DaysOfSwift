# Local notification  - Project 21 0f #100DaysOfSwift

## Description:
This is a simple project where we learned about setting up local notifications, and how to send reminders to the user's locks screen, and show info when the app is not running.


## Key points:
Notifications, UNUserNotificationCenter, UNNotificationRequest

## Challanges:
From Hacking with Swift:

1. Update the code in didReceive so that it shows different instances of UIAlertController depending on which action identifier was passed in.
2. For a harder challenge, add a second UNNotificationAction to the alarm category of project 21. Give it the title “Remind me later”, and make it call scheduleLocal() so that the same alert is shown in 24 hours. (For the purpose of these challenges, a time interval notification with 86400 seconds is good enough – that’s roughly how many seconds there are in a day, excluding summer time changes and leap seconds.)
3. And for an even harder challenge, update project 2 so that it reminds players to come back and play every day. This means scheduling a week of notifications ahead of time, each of which launch the app. When the app is finally launched, make sure you call removeAllPendingNotificationRequests() to clear any un-shown alerts, then make new alerts for future days.

## Screenshots:

<img width="349" alt="1" src="https://github.com/AleksandraSRB/100DaysOfSwift/assets/94380380/a052d67b-5e40-4881-8146-1f33ef0705d6">

<img width="352" alt="2" src="https://github.com/AleksandraSRB/100DaysOfSwift/assets/94380380/5c2e02f6-3035-4894-97a5-26698174d449">

<img width="352" alt="3" src="https://github.com/AleksandraSRB/100DaysOfSwift/assets/94380380/8904a1cf-1437-4744-a534-77137988d4ba">

<img width="355" alt="4" src="https://github.com/AleksandraSRB/100DaysOfSwift/assets/94380380/1a839f74-3695-447f-8d65-f1bdd6aa0d54">
