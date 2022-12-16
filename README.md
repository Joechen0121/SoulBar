<p align="center">
<img src="https://user-images.githubusercontent.com/41284285/207876439-915ac629-88d2-4d91-96fc-ca5af0d1bf54.png" height="300">
</p>

# SoulBar

Recognized the playing music or humming voice and found the related information of the song. Also, SoulBar contained multiple additional features for searching music, favorite music lists, and information of Taiwan events.

# Table of Contents
1. [Requirements](#Requirements)
2. [Limitations](#Limitations)
3. [Features](#Features)
4. [App Store Link](#App-Store-Link)
5. [Contact](#Contact)
6. [Resources](#Resources)

## Requirements 

| Item                  | Supported         |
| -------------         |:-------------:    |
| iPhone version        | iOS 15+           |
| Swift version         | 5+                |
| OpenAI feature        | Support in `branch dev`|

## Limitations
| Item                  | Limitations       |
| -------------         |:-------------:    |
| Song durations        | 30 seconds only   |
| Dark / Light mode     | Light mode only   |
| Orientation           | Portrait only     |

## Features
* **Recognition**
    * Implemented `ShazamKit` for audio recognition and searched matched songs in `MusicKit`.<br/><br/><img src="https://user-images.githubusercontent.com/41284285/207873855-2cce5513-7d28-4fd6-bbe8-618f2e2d3f07.png" height="450"><br/><br/>
    * Connected to `ACRCloud` API to enable user humming recognition.<br/><br/><img src="https://user-images.githubusercontent.com/41284285/207874720-a14b00af-642f-4e32-abd3-67e4ba3c5917.png" height="450"><br/><br/>
* **Music player**
    * Operated music, such as play/pause, next/previous, and remote background control using `AVFoundation`.<br/><br/><img src="https://user-images.githubusercontent.com/41284285/207874728-ec6ce534-180f-47fe-9225-f3b9e478b528.png" height="450"><br/><br/>
* **Searching**
    * Searched dynamically when user continuesly types the words.
    * Used face detection of celebrities when you don't remember someone's face using `AWS Rekognition`.<br/><br/><img src="https://user-images.githubusercontent.com/41284285/207874735-4d6cb55a-f49e-4cd3-a750-f02397b9e72d.png" height="450"><br/><br/>
    * Translated audio content into text using `Speech` in two languages options.<br/><br/><img src="https://user-images.githubusercontent.com/41284285/207874746-23339e26-795d-4b0b-858b-d3e99a2b40d5.png" height="450"><br/><br/>
* **Siri shortcut**
    * Navigated to the recognizing page from iPhone home screen using `SiriKit` shortcut to enhance convenience.<br/><br/><img src="https://user-images.githubusercontent.com/41284285/207874750-6f8867e1-b803-44d9-aa24-edc82a8013d5.png" height="450"><br/><br/>
* **Firebase usage**
    * Stored favorite songs, playlists, artists data in storage - `Firebase Storage`
    * Dynamically turned on/off function - `Firebase Remote Config`
    * Analyze crash status or log - `Firebase Crashlytics`<br/><br/><img src="https://user-images.githubusercontent.com/41284285/207874833-f74ca7b5-59e3-40ac-86e7-9c7a52eba84f.png" height="450"><br/><br/>
* **OpenAI (Ongoing)**
    * Got responses from one question at once - `OpenAI`
    * Hardcoded model `text-davinci-003`
        * If you need to change model, please refer to OpenAI Manager file.
        * If OpenAI key is revoked, please get information in [OpenAI](https://openai.com/) and change the key in OpenAI Manager.
    <br/><br/>
    <img src="https://user-images.githubusercontent.com/41284285/207874844-56901c2a-d1f3-483f-b65e-6b6c6cb2b65b.png" height="450">
    <br/><br/>
## App Store Link
[SoulBar](https://itunes.apple.com/app/id6444237194)

## Contact 
- E-mail (s900567@yahoo.com.tw)
- [Linkedin](https://www.linkedin.com/in/Chen-Chien-Lun)

## Resources 

- Apple Developer Document
    - [MusicKit](https://developer.apple.com/documentation/musickit) 
    - [ShazamKit](https://developer.apple.com/documentation/shazamkit)
    - [AVFoundation](https://developer.apple.com/documentation/avfoundation)
    - [Speech](https://developer.apple.com/documentation/speech)
    - [SiriKit](https://developer.apple.com/documentation/sirikit)
    
- [AWS rekognition](https://aws.amazon.com/tw/rekognition/)
    
- [Firebase](https://firebase.google.com/)

- [ACRCloud](https://www.acrcloud.com/)
