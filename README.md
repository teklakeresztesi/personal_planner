# Personal Planner
This is a personal planner app written in objective-c as a preparation for an interview.

# Usage

This app works on iOS 18.5 or newer. Using a physical device is recommended due to voice recognition might not work properly on a simulator.

The app starts by asking for permissions to use the microphone and speech recognition. After granting permission, the app starts to listen to voice commands.

Voice commands can be:
- schedule an event
- reminder
- add something to a to do list
- stop listening

# Testing

Currently there are unit tests for the CommandParser class which can be found in the PersonalPlannerTests/Utils/CommandParserTests.m file.   
Tests follow the Arrange-Act-Assert pattern.


