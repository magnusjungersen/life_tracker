# Life Tracker
Personal custom mobile app for tracking daily activities, mood etc.

Personal app for tracking my mood, productivity, feelings and activities. No statistics or fancy graphics are included to bias your view. 

- Will per default give reminder notifications at 9 AM and 10 PM. 

## Files needed
Assets folder expects config.json:
{
  "release": {
    "spreadsheetID": "your spreadsheetID",
    "worksheetTitle": "your worksheetTitle"
  }
}

and credentials.json for google sheets document. 

### How to install
- Using VS Code flutter plugin is recommended. 
- Connect phone and make sure device is connected in VS code. 
- "flutter run --release" in terminal to install production version on device
- ???
- Tracking

### Current problems
- Missing icon for notifications
- Option for modifying data in app
- Notification timezones are off
