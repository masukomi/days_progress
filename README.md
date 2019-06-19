# Day's Progress

Day's Progress is a simple little command line utility to give you a sense of your progress through the day. 

It looks like this (only smaller):

![day's progress example image](days_progress_example_image.png)

## Usage

After installing and configuring (see below) just run `days_progress` in your terminal. That's it.



## Installation
### MacOS via Homebrew
Execute the following lines in your terminal.

```sh
brew tap masukomi/homebrew-apps
brew install days_progress
```

### Building from source
Requires [Chicken Scheme](http://call-cc.org/) >= 5.0

Compile it by executing the following lines in your terminal

```sh
# Install the required eggs (libraries)
# (You only have to do this once)
chicken-install filepath
chicken-install simple-loops
chicken-install ansi-escape-sequences

# Now compile the code
csc days_progress.scm
```

Then move the new `days_progress` file somewhere on your [PATH](https://youtu.be/rJMFxIbDe-g).

## Configuration
You need to tell `days_progress` what you consider the start and end of _your_ day to be. 

It uses a simple configuration file that needs to live at 

```
~/.config/days_progress/days_progress_config.scm
```

Mine looks like this. If it looks a little weird to you that's becasue this is actually a tiny program in Chicken Scheme.

To get started I recommend editing the [days_progress_config.scm](days_progress_config.scm) file in this repository, and then moving it to the location above.

```scheme
(define my-utc-offset -4)
(define start-hour-local 9)
(define end-hour-local 21)
(define start-hour-label "9 EDT")
(define end-hour-label "6 PST")
```

### Here's what each of those means

What is the UTC offset for my current time zone?

```scheme
(define my-utc-offset -4)
```

What hour of the day do I consider the "start" (in my time zone)?

```scheme
(define start-hour-local 9)
```
What hour of the day do I consider the "end" (in my time zone)?

```scheme
(define end-hour-local 21)
```

The labels are for display only. I use
"9 EDT" and "6 PST" because I start work at 9 AM EDT
and my coworkers _end_ their day at 6 PM PST
I could also say "New York" and "California" if 
that felt better.
If you want _no_ labels to be displayed use 
empty strings. E.g. `""`

What label do I want shown at the start of the output?

```scheme
(define start-hour-label "9 EDT")
```
What label do I want shown at the end of the output?

```scheme
(define end-hour-label "6 PST")
```
