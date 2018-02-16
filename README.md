<h1>Introduction</h1>
    INTUZ is presenting a iCloud Sync Manager component for your iOS native application, which has functionality to sync application data to your iCloud account.
<br>

<h1>Features</h1>
    This component has wraper class from which developer can easy to integrate iCloud syncing functionalty with two types of syncing functionality. 
    
    1. iCloud Sync using Key Value paring
    2. iCloud Sync using Document Storage
<br/>

<h1>Getting Started</h1>
<br/>   Add iCloud.framework in in project library.

    1. iCloud Sync using Key Value paring
       #import "iCloudKeyValueManager.h"
      - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
            iCloudKeyValueManager *iCloudKeyValueManager = [[iCloudKeyValueManager alloc]init];
            [iCloudKeyValueManager setupiCloudEnableKey];
        }
        Note :  
            1. 'addObserverForiCloud' method is used to monitor iCloud events including push and recieve updates from iClouds.
            2. 'removeObserverForiCloud' method is used to stop monitoring iCloud events.
<br/>

    2 iCloud Sync using Document Storage
        #import "iCloudSyncManager.h"
        - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
            iCloudSyncManager = [iCloudSyncManager sharedInstance];
            [iCloudSyncManager setupiCloud];
        }
        Note :  
            1. 'addObserverForSaveDocumentToiCloud' is used to save and update application prefrence file (i.e. A file which needs to sync with iCloud).
            2. 'removeObserverForSaveDocumentToiCloud' is used to stop monitoring of iCloud document storage event.	
<h1>Bugs and Feedback</h1>
For bugs, questions and discussions please use the Github Issues.

<h1>Acknowledgments</h1>

<a href="https://github.com/iRareMedia/iCloudDocumentSync" target="_blank">iCloudDocumentSync</a>

<h1>License</h1>
The MIT License (MIT)
<br/><br/>
Copyright (c) 2018 INTUZ
<br/><br/>
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: 
<br/><br/>
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

<br/>
<h1></h1>
<a href="https://www.intuz.com/" target="_blank"><img src="Screenshots/logo.jpg"></a>
