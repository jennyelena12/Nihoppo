# Nihoppo

## Overview

Nihoppo is a personalized Japanese learning app built with SwiftUI and on-device AI. The application helps learners create a study routine based on their current Japanese proficiency, weak areas, available study time, and preferred study schedule.

Users begin with a placement quiz that evaluates their Japanese skills and determines their current proficiency level. Based on the quiz results and study commitment, Nihoppo generates a personalized 7-day study plan using an AI model and allows the plan to be added directly to the user's calendar.

## Features

* Japanese placement quiz with progress tracking
* Automatic proficiency level assessment
* Identification of weak learning areas
* Personalized study plan generation
* Customizable daily study duration
* Customizable preferred study time
* Multiple AI model providers
* Apple Foundation Models integration
* Qwen on-device model integration
* Llama on-device model integration
* Calendar integration using EventKit
* Add generated study plans directly to Apple Calendar
* SwiftData persistence for study commitments
* Responsive and interactive SwiftUI interface

## Tech Stack

* Swift
* SwiftUI
* SwiftData
* Foundation Models
* EventKit
* Observation
* MLX
* Qwen
* Llama
* Xcode

## Project Structure

```text
.
├── Nihoppo.xcodeproj/                  # Xcode project configuration
├── Nihoppo/
│   ├── NihoppoApp.swift                # Application entry point
│   ├── Info.plist                      # Application configuration
│   ├── Assets.xcassets/                # App icons and visual assets
│   │
│   ├── Model/
│   │   ├── QuizModel.swift              # Quiz questions and proficiency models
│   │   ├── StudyModel.swift             # Study commitment data model
│   │   ├── StudyPlan.swift              # Study plan data structures
│   │   ├── StudyPlanGenerator.swift     # AI study plan generation
│   │   └── MLModels/
│   │       ├── FoundationModelPlanGenerator.swift
│   │       ├── QwenPlanGenerator.swift
│   │       └── LLamaPlanGenerator.swift
│   │
│   ├── Services/
│   │   └── CalendarService.swift        # Apple Calendar integration
│   │
│   ├── View/
│   │   ├── HomeView.swift               # Main application screen
│   │   ├── QuizView.swift               # Placement quiz interface
│   │   ├── CommitmentSetupView.swift    # Study commitment setup
│   │   ├── StudyPlanView.swift          # Generated study plan
│   │   └── NihoppoTheme.swift            # Application theme and styling
│   │
│   └── ViewModel/
│       ├── QuizViewModel.swift           # Quiz state and scoring logic
│       ├── CommitmentSetupViewModel.swift
│       └── StudyPlanViewModel.swift      # Study plan generation and calendar logic
│
└── README.md
