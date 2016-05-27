Hey everybody, welcome to tutorial 14, where we'll start creating some basic graphical user interfaces, usually called G-U-I or GUI for short. GUIs can provide an intuitive intermediate layer between the user and the code, which as you can probably imagine, is pretty useful in a lot of situations. On the surface, it might not seem like SuperCollider is much of a GUI-capable program, but in fact it's quite richly featured when it comes to creating graphical functionality. In this video, we'll look at a broad overview of some common objects, their essential behaviors, and how to create a manipulate them.

I recommend you take a look at the guide called Introduction to GUI, which is good resource for general information. And, within the SuperCollider application folder, there's an examples folder, and within it, a folder called GUI examples, which is another good resource.

So, let's begin. A graphical interface begins with a new window, which we can create with Window dot new.

w = Window.new;

So, first of all...a very obvious question-- where is the window? A newly created window is invisible by default. We can change this using the 'front' message, which does two things: it sets the window's visible attribute to be true, and brings the window forward to the frontmost position.

w.front;

Now, since I'm going to be typing a lot of code, it'll be useful to have this window remain in the frontmost position, so I'm not constantly switching back and forth between the window and the code environment. Windows have an attribute called 'alwaysOnTop'. If we ask for this value, we see that currently, it's false.

w.alwaysOnTop;

We can change this by setting the attribute equal to true.

w.alwaysOnTop = true;

and now our new window remains on top, and it doesn't matter if its in focus or not. So, whenever you're setting a value for some attribute of an object, as we've just done, there's an alternate syntax. Instead of attribute-equals-value, we type attribute-underscore- and the value in parentheses. I tend to prefer the underscore syntax because it allows you to concatenate several methods together in one statement. And I want to introduce this syntax early on, because I'll be using it a lot. You can find this syntax shortcut and many others in a reference file called Syntax Shortcuts.

w.alwaysOnTop_(false);
w.alwaysOnTop_(true);

You can close the window with '.close', keeping in mind that x-ing it out with the mouse invokes the exact same behavior.

w.close;

When the window is closed, the instance is permanently destroyed, so we can't re-open the window or otherwise access it. As you can see, front no longer works.

w.front;

So here's a new window, and notice I'm able to string these three methods together. I'm using a multi-line approach because I think it's easier to read.

( //clear post
w = Window.new
.front
.alwaysOnTop_(true);
)

Now take a look at the post window. We've asked for a new window, but SuperCollider returns a QWindow. Why does this happen? This behavior is the result of SuperCollider's GUI redirect system. And to help explain what this is and how it works, I'm going to open a help file called List of GUI classes. So at any point in time, one and only one GUI kit is active. When the user asks for a generic GUI object, SC defers to the active GUI kit, and returns the corresponding object that belongs to that Kit.

GUI.current;

GUI dot current returns the active kit, which for me happens to be Qt GUI. This means that when I ask for a new Window, what I actually get is a QWindow. Of course, I could ask for a QWindow directly,

(
w = QWindow.new
.front
.alwaysOnTop_(true);
)

but the problem here, is that if I then gave this code to someone using a different GUI kit, this code wouldn't work correctly. For example,

(
w = SCWindow.new
.front
.alwaysOnTop_(true);
)

even though a class called SCWindow supposedly exists, we get an error. In fact, in this case,

GUI.cocoa; //scroll down HF a bit

the Cocoa GUI kit isn't even installed. So the bottom line, is you should always use the generic names in the leftmost column here, and let the redirect system handle the rest. And in fact, the Introduction to GUI help file spells it out plain and simple.

We now have two windows open, and they're both named w. This means w.close is only going to work on the window that was created most recently.

w.close;

But if you ever find yourself with multiple open windows, intentionally or unintentionally, you can always rely on the class method 'closeAll'.

Window.closeAll; //then clear post

Ok, moving on, let's talk about size and placement.

(
w = Window.new
.front
.alwaysOnTop_(true);
)

Every graphical object has an attribute called 'bounds', which determines the size and location of the rectangular space which the object occupies.

w.bounds;

an object's bounds is represented by an instance of a class called Rect, whose four arguments represent x position, y position, width, and height, all measured in pixels. If we move and/or resize the window, bounds returns a different Rect

w.bounds;

Specifically, the first two numbers are the xy coordinates of the lower left corner of the window, relative to the lower left corner of the screen. The third and fourth numbers are the width and height of the window. So, in its current state, the bottom left corner of the window is [] pixels from the left side of my screen, [] pixels from the bottom, [] pixels wide and [] pixels tall. We can alternatively modify the bounds by evaluating code like this

w.bounds_(Rect.new(1000,400,200,200));

w.close;

When we create a new window, we have the option of specifying the initial bounds as an input argument.
//Window HF
The first argument to Window.new is a string that will appear in the window's title bar, and the second argument is the bounds. Then there are a few other arguments which I usually don't bother with, and they're well documented in the Window help file.

(
w = Window.new("gui", Rect.new(750,50,500,200))
.front
.alwaysOnTop_(true);
)

If you want to place a window somewhere specific, but irrespective of any particular screen resolution, the class method screenBounds is very useful.

Window.closeAll; //clear post

Window.screenBounds;

The method itself returns an instance of Rect that would theoretically fill your entire screen. So let's imagine we want to put a 200x200 window in the absolute center of the screen. In the help file for Rect, we can see a number of instance methods, including width and height,

Window.screenBounds.height;

So we can calculate the center pixel of the screen by dividing both width and height by 2. But this alone will put the lower left window corner in the middle of the screen, so to compensate, we subtract half the width and height of the window.

(
w = Window.new(
	"gui",
	Rect.new(
		Window.screenBounds.width/2-100,
		Window.screenBounds.height/2-100,
		200,
		200
	)
)
.front
.alwaysOnTop_(true);
)

And this should place a window in the exact center of the screen, regardless of screen resolution.

So now, we'll start talking about some more familiar and more functional GUI objects. And to do this properly, I'm going to begin by introducting a class called View. View is the parent class of all GUI objects, including knobs, sliders, buttons, menus, realistically any visible element is a subclass of View. The only exception is Window, which is related, but for the most part, its own separate class. Of course, this means that all of the methods defined for View are inherited by its numerous subclasses, and so within the world of SuperCollider GUI, there's a very pervasive and convenient homogeneity. In plainspeak, if you know how to deal with one type of GUI object, you can very easily apply this understanding to other GUI objects.

(
Window.closeAll;
w = Window.new("gui", Rect.new(750,50,500,200))
.front
.alwaysOnTop_(true);
)

So I'm going to start with a Slider, which I think is one of the simplest and most straightforward GUI objects.

//HF for Slider?

View, and all of its subclasses, expects at least two inputs. First is the parent view, which, in other words, is the visual space on which the object will reside. So this requires just a quick explanation here. Whenever we create a window, the rectangular space which occupies the main part of the window is in fact, itself, a type of View. In this case, it's an instance of the subclass called QTopView

w.view;

And this sort of reinforces the fact that really any graphical entity is some kind of View. So for the parent view for our slider, w.view is basically our one and only sensible option here.

The 2nd input argument is the object's bounds, so we provide a new instance of Rect. And here, there's a minor but important difference here. When we create a Window, the origin of the parent space is in the lower left corner of the screen. But when we place Views on a Window, the origin of the parent space is actually the upper left corner of the parent view. So here, our slider is 20 pixels away from the left side of the window, 20 pixels from the top, 150 pixels wide, and 30 pixels tall.

~slider = Slider.new(w.view, Rect.new(20,20,150,30));

Of course...our slider doesn't really do anything yet, because we've only specified its parent view and bounds. We'll will make this slider do something, but first, here are a few very basic ways of manipulating views.

The parent message returns the instance of the parent view, in this case, the TopView that occupies our Window

~slider.parent;

And a view will respond to the children message by returning an array containing all the views which have been placed on it, in this case, an array containing one slider.

w.view.children;

This is a convenient way to address every view within a given space, rather than having to address them all individually.

Views can be hidden and un-hidden by setting the visible attribute to be false or true

~slider.visible_(false);
~slider.visible_(true);

We can modify the bounds of a view just like we modify a window's bounds, keeping in mind that the first two values of the Rect are with respect to the upper left corner of the parent space, not the lower left corner.

Here I'm moving the slider farther away from the corner
~slider.bounds_(Rect.new(40,40,150,30));

And here I'm lengthening the slider and making it a bit thinner.
~slider.bounds_(Rect.new(40,40,200,20));

The 'enabled' attribute determines whether the user can interact with the object. When false, the mouse no longer has any effect.

~slider.enabled_(false);
~slider.enabled_(true);

And the method "remove" will destroy the instance, after which it becomes inaccessible. And to reinforce this, we can see that the array of children is now empty.


~slider.remove;

w.view.children;

w.close;

We'll start fresh once again, and this time I'll show a few syntax shortcuts that might make your life a little easier. In practically every case, you can omit dot new, and SuperCollider correctly assumes that 'new' is the method you want. And, at least in QtGUI, if you're placing Views on a window, you can omit the .view when specifying the parent space. This works for QtGUI, and I'm pretty sure the works for other GUI kits, but I'm not positive. So if you're using another kit, you can try it out for yourself and see if SuperCollider complains.

(
Window.closeAll;
w = Window("gui", Rect(750,50,500,200))
.front
.alwaysOnTop_(true);

~slider = Slider(w, Rect(20,20,150,30));
)

Ok, so let's get a bit more specific here, and talk about behavior and functionality. At any given point in time, a GUI object has some state, which is often but not always some numerical value. And it's very often the case that we want to either retrieve and/or alter this value, this is most often referred to as getting and setting a value. We can get the state of our Slider with the 'value' message.

~slider.value;

which happens to be zero. And we can set the slider's value just like any other attribute

~slider.value_(0.25);
~slider.value_(0.8);

By default, Sliders and other number-based objects have a range of zero to one. Of course we can also change the value by simply clicking and dragging the slider.

Another very important feature of GUI objects is their action, which is a function that is evaluated whenever the user interacts with the object. Without specifying otherwise, a object's action is nil, which means no action is performed.

~slider.action;

But we can change this by setting the action to be whatever function we like.

~slider.action_({"I am a slider".postln});

So now, whenever we interact with the slider, this function is evaluated. Now, in many cases, you'll want to somehow incorporate the current value of the slider into the output of the action function.

So to do this, we declare an argument at the beginning of the action function, of course you can name this argument whatever you like, and SuperCollider interprets this argument as the instance of the GUI object itself. In this case, obj represents the slider. And so this declaration allows us to then access the slider's attributes within the action function. To begin, let's simply post the value of the slider.

(
~slider.action_({
	arg obj;
	obj.value.postln;
});
)

So now, each time we move the slider, the action function is evaluated, which prints the current value in the post window.

And this brings us to another important method, which is valueAction, with a capital A. valueAction is a method that not only sets a new value, but also performs the action. valueAction is distict from value, which only gets or sets the value, and does not perform the action. And so here's a quick demonstration. The value method changes the state of the slider, but we see no numerical value printed in the post window, which means the action is not invoked.

~slider.value_(rrand(0.0,1.0));

valueAction changes the state, but also performs the object's action, whatever that action might be.

~slider.valueAction_(rrand(0.0,1.0));

As we move forward, you'll see that this distinction is actually a very important one.

Before we get too involved, I want to just briefly introduce some ways you can customize the appearance of GUI objects-- colors in particular. It's very natural to want to customize the color scheme and other visual aspects of your interface to give it a more personal feel. And so here, I often access the 'background' attribute, which refers to the color of whatever is considered the background of that object.

~slider.background;

background returns an instance of Color, which has four floating point inputs: red, green, blue, and alpha, which all range from 0 to 1. For the first three color values, 1 is full presence of that color, 0 is total absence. For alpha, 1 means fully opaque, zero is transparent. Alpha is sometimes omitted, as it is here in the post window, and defaults to a value of 1.

So let's change the slider background color. The most basic Color method is .new, which, again, we are free to omit, if we like. Here's a mix of full red, half green, and no blue.

~slider.background_(Color(1,0.5,0));

There are a few specific methods for common colors like .green, .magenta, etc.

~slider.background_(Color.green);
~slider.background_(Color.magenta);

if we provide one input value for one of these methods, it's interpreted as an interpolation between full color, and black

~slider.background_(Color.magenta(0.8));
~slider.background_(Color.magenta(0.5));
~slider.background_(Color.magenta(0.0));

There's also Color.rand, which chooses random RGB values based on a given minimum and maxiumum, which by default is between 0.3 and 0.9.

~slider.background_(Color.rand);

Recall, that the window space itself is also a view, so we can change its background color too.

w.view.background_(Color.rand);

So we could even do something totally ridiculous, like randomizing the background color whenever the action is called.

(
~slider.action_({
	arg obj;
	w.view.background_(Color.rand(0.0,1.0));
	obj.value.postln;
});
)

But I think most of us will agree, this is a little extreme. We could do something similar, but much more subtle, by using Color.new and incorporating some simple arithmetic to constrain these color values.

(
~slider.action_({
	arg obj;
	w.view.background_(
		Color(obj.value*0.3+0.7,0.8,0.4)
	);
	obj.value.postln;
});
)

Let's give our slider a blend of mostly blue and green
~slider.background_(Color(0.2,0.75,0.95));

We can also set the color of the slider's handle with the message knobColor. Now it's white, now it's black.

~slider.knobColor_(Color.white);
~slider.knobColor_(Color.black);

And we can also set the size of the slider handle with thumbSize-- 40 pixels, 20 pixels.

~slider.thumbSize_(40);
~slider.thumbSize_(20);

Keep in mind that methods like knobColor and thumbSize aren't going to apply to every GUI object, because they're all different from one another and some of them...don't have knobs. So it's always a good idea to check the object's help file for specifics. And in fact I often find myself going back to these help files periodically to refresh my memory.

Ok so. Let's make this slider do something. So it's time to boot the audio server.

s.boot;

Because we're focusing on GUI, I'm going to keep the audio fairly simple, and just have this slider control a center frequency of a bandpass filter. So here's a simple SynthDef for filtering pink noise, in which we have an argument for the center frequency of the filter

(
SynthDef.new(\simplebpf, {
	arg freq=440;
	var sig;
	sig = PinkNoise.ar(1!2);
	sig = BPF.ar(sig, freq, 0.2);
	Out.ar(0, sig);
}).add;
)

And now let's modify the slider's action. First of all, a range of zero to one is totally inappropriate as the frequency input to a filter. So I'm going to declare a variable, cf for cutoff frequency, and map the slider's value from a linear range of 0 to 1 onto an exponential range of 100 to 4000. I'll point out that there is an object called ControlSpec, which is designed to map from one range and interpolation curve to another. But, honestly, I don't actually use this object very much, probably I should use it more, but I don't. I'm not going to spend any more time on ControlSpec in this video, but regardless, I do encourage you to look at the examples in the ControlSpec help file, in case you might find it useful. So, back to our example, theoretically, we're going to have some Synth running on the server, for the sake of simplicity I'm just going to store it in the variable x. So the last step here is to update the frequency argument using the rescaled value.

(
Window.closeAll;
w = Window("gui", Rect(750,50,500,200))
.front
.alwaysOnTop_(true);

~slider = Slider(w, Rect(20,20,150,30))
.background_(Color(0.2,0.75,0.95))
.action_({
	arg obj;
	var cf;
	cf = obj.value.linexp(0,1,100,4000).postln;
	x.set(\freq, cf);
});
)

Finally, we create the Synth.

x = Synth(\simplebpf); //move slider
x.free;

Ok so this example actually has some problems.  First of all, if we make a large instantaneous jump in the slider's value, we hear a horrible pop.

x = Synth(\simplebpf); //move slider
x.free;

Yeah, it's actually pretty terrible. This is a consequence of controlling an otherwise continuous signal with discrete values that are not necessarily continuous, and this kind of thing is especially prominent when dealing with filters. One of the best solutions here is to change the UGen function by lagging the frequency values. dot-lag causes the signal to interpolate between successive values over a given time interval, which in effect translates the discrete data into a smoother stream of values. If the lag time is too short, the smoothing effect won't be strong enough to counteract the problem, but if the lag time is too long, the signal becomes sluggish and unresponsive. So I'm going to specify half a second.

(
SynthDef.new(\simplebpf, {
	arg freq=440;
	var sig;
	sig = PinkNoise.ar(1!2);
	sig = BPF.ar(sig, freq.lag(0.5), 0.2);
	Out.ar(0, sig);
}).add;
)

x = Synth(\simplebpf); //move slider, stop at top position
x.free;

So that's an improvement. Although the slider is not quite as responsive as before, we've gotten rid of that disgusting pop.

Another problem with this example is that we're starting the Synth with a default frequency of 440, but there's no guarantee that the value of the slider is in the correct corresponding position. Like, right now for example- our slider is at the top of its range. So it actually corresponds to 4000Hz. This means if we start the Synth, the initial sound won't match initial state of the slider.

x = Synth(\simplebpf);
x.free;

We can correct this by initializing the frequency argument of the Synth according to the slider's value, making sure to map the value to the appropriate range.

(
x = Synth(
	\simplebpf,
	[\freq, ~slider.value.linexp(0,1,100,4000)]
); //move slider
)

x.free;

Instead of starting and stopping the sound by evaluating code, let's introduce the Button object, again just starting with parent view and bounds.

~button = Button(w, Rect(430,20,50,30));

The button object is capable of having any number of states, and when the button is clicked, we cycle through these states. To start and stop sound with one button, we're essentially talking about a toggle button, which has two states.

So how do we define a button's states? we provide an Array containing as many internal arrays as the number of states we want, in this case, two. Each of these internal arrays will contain a string, the string color, and the background color. So state number zero is the "off" state, and state number one is the "on" state. When the button is in state 1, let's give it the same background color as the slider.

~button.states_([ ["OFF", Color.black, Color.gray(0.8)], ["ON", Color.white, Color(0.2,0.75,0.95)] ]);

We've effectively created a toggle button. We can cycle through these two states by clicking, and we can also specify a jump to a particular state, using the value message, like we did with the slider.

~button.value_(1);
~button.value_(0);

Keeping in mind that we used valueAction instead of value, we would simultaneously update the value and invoke the action function.

Any GUI object that involves text can have it's typeface changed with the 'font' message. We can set the font by providing an instance of a class simply called Font. And again, I recommend reading taking some time to read through this help file to get more thorough understanding. An instance of Font needs the name of the font, specified as a string, and the font size.

~button.font_(Font("Monaco", 18));

But it's really important to remember that not everybody is going to have the same font library that you have. If you specify some bogus font, at best, SuperCollider will just go back to some default font.

~button.font_(Font("totally bogus", 18));

So, personal recommendation, don't let yourself get too carried away customizing fonts, or colors for that matter. I'll be first to admit that visually customizing an interface is a lot of fun, but I like to think of it as having dessert after slaving over a huge dinner. It can be really enjoyable, but it's not absolutely necessary, and sometimes, I skip dessert altogether.

~button.font_(Font("Monaco", 18));

Ok, so we've set up our button to have two states, and now we need to define its action. First things first, in the action function, we need to declare an argument in order to access the button itself, because we need to know the state of the button to determine whether we should be starting or stopping the sound. And so here, a conditional statement is in order. In plain english, if the button is on, start the sound. if not, stop the sound.

(
~button.action_({
	arg obj;
	if(
		obj.value == 1,
		{x = Synth(\simplebpf, [\freq, ~slider.value.linexp(0,1,100,4000)])},
		{x.free}
	);
});
)

So for the most part, this is working, but watch what happens if I move the slider while the button is off. Right. Node not found. The slider is trying to set values for a Node that only exists when the button is on. Now you can probably imagine a variety of solutions to this problem-- for example, you could disable the slider or make it invisible whenever the button is off. But I think the cleanest and simplest solution is to register the synth with an object called NodeWatcher, and we can read about this option in the help file for Node. Once a Synth or Group has been registered, NodeWatcher enables two methods: isPlaying and isRunning, and this is perfect for conditional statements.

So here are the changes we need to make. When the Synth is created, we simply append the message "register". Then, we include a conditional statement in our Slider's action that will check to make sure the Synth exists, before attempting to update its frequency argument.

(
Window.closeAll;
w = Window("gui", Rect(750,50,500,200))
.front
.alwaysOnTop_(true);

~slider = Slider(w, Rect(20,20,150,30))
.background_(Color(0.2,0.75,0.95))
.action_({
	arg obj;
	var cf;
	cf = obj.value.linexp(0,1,100,4000).postln;
	if(
		x.isPlaying,
		{x.set(\freq, cf)}
	);
});

~button = Button(w, Rect(430,20,50,30))
.states_([
	["OFF", Color.black, Color.gray(0.8)],
	["ON", Color.white, Color(0.2,0.75,0.95)]
])
.font_(Font("Monaco", 18))
.action_({
	arg obj;
	if(
		obj.value == 1,
		{x = Synth(\simplebpf, [\freq, ~slider.value.linexp(0,1,100,4000)]).register},
		{x.free}
	);
});
)

And now, the Failure messages we saw earlier are gone.

Let's add a Knob to control the quality of the filter. First, we need to add a quality argument to the SynthDef. And I'm also going to incorporate the quality of the filter into the filter's mul argument. When the filter's pass band narrows, the amplitude decreases. And multiplying by this value will ensure that the amplitude will remain more or less constant, regardless of the filter quality.

(
SynthDef.new(\simplebpf, {
	arg freq=440, rq=0.2;
	var sig;
	sig = PinkNoise.ar(1!2);
	sig = BPF.ar(
		sig,
		freq.lag(0.5),
		rq.lag(0.5),
		1/rq.sqrt.lag(0.5)
	);
	Out.ar(0, sig);
}).add;
)

And now we add the Knob and give it an appropriate action function, making sure that it also checks whether the Synth is playing. And also we make sure to incorporate the value of the Knob when the Synth is created.

(
Window.closeAll;
w = Window("gui", Rect(750,50,500,200))
.front
.alwaysOnTop_(true);

~slider = Slider(w, Rect(20,20,150,30))
.background_(Color(0.2,0.75,0.95))
.action_({
	arg obj;
	var cf;
	cf = obj.value.linexp(0,1,100,4000).postln;
	if(
		x.isPlaying,
		{x.set(\freq, cf)}
	);
});

~knob = Knob(w, Rect(180,20,30,30))
.action_({
	arg obj;
	var qual;
	qual = obj.value.linexp(0,1,1,100).reciprocal;
	if(
		x.isPlaying,
		{x.set(\rq, qual)}
	);
});

~button = Button(w, Rect(430,20,50,30))
.states_([
	["OFF", Color.black, Color.gray(0.8)],
	["ON", Color.white, Color(0.2,0.75,0.95)]
])
.font_(Font("Monaco", 18))
.action_({
	arg obj;
	if(
		obj.value == 1,
		{
			x = Synth(
				\simplebpf,
				[
					\freq,
					~slider.value.linexp(0,1,100,4000),
					\rq,
					~knob.value.linexp(0,1,1,100).reciprocal
				]
		).register},
		{x.free}
	);
});
)

It's possible and sometimes desirable to have the action of one GUI object affect one or more other GUI objects. As a very simple example, let's create a number box that will reflect the value of the Slider, scaled to our frequency range of 100 to 4000 Hz.

I'd like to put this number box right next to the Slider, so first I'll move my knob to the right:

~knob.bounds_(Rect(270,20,30,30));

And now for the NumberBox. I'll initialize the value at 100, and since this number represents the center frequency, clip it within our desired range so we don't accidentally get bad values. I'll keep the font consistent with the button font, and limit the display to two decimal places-- again, all of these methods can be found in the help file. So the only parts that requires some careful attention are the action functions. We want the slider to update the number box, and vice versa, because they're both supposed to represent the same thing. So let's start with the Slider. Whenever the slider's action is called, we want to update the value of the numberbox, making sure to rescale the values appropriately. And we want to do more or less the same thing with the number box, except, it's not enough to just call 'value' on the slider. The slider is the object responsible for controlling the sound, so we actually need to call valueAction on the slider-- that is to say, update its value and have it execute its function. However, what we DON'T want to do is have both objects call valueAction on each other. Because if this were the case, as soon as we interact with either of these two objects, they'll invoke each other's action back and forth, back and forth, back and forth, and this creates an infinite loop and the interpreter will totally crash. So I find it useful to conceive of one GUI object in particular as being the active one, in this case, the slider which handles everything-- controlling the sound, and updating other passive GUI objects, such as the number box. Any passive GUI objects are only responsible for relaying the request to the one active object and asking it to perform its function.

(
Window.closeAll;
w = Window("gui", Rect(750,50,500,200))
.front
.alwaysOnTop_(true);

~slider = Slider(w, Rect(20,20,150,30))
.background_(Color(0.2,0.75,0.95))
.action_({
	arg obj;
	var cf;
	cf = obj.value.linexp(0,1,100,4000).postln;
	if(
		x.isPlaying,
		{x.set(\freq, cf)}
	);
	~numberBox.value_(obj.value.linexp(0,1,100,4000));
});

~numberBox = NumberBox(w, Rect(180,20,80,30))
.value_(100)
.clipLo_(100)
.clipHi_(4000)
.font_(Font("Monaco", 16))
.decimals_(2)
.action_({
	arg obj;
	~slider.valueAction_(obj.value.explin(100,4000,0,1))
});

~knob = Knob(w, Rect(270,20,30,30))
.action_({
	arg obj;
	var qual;
	qual = obj.value.linexp(0,1,1,100).reciprocal;
	if(
		x.isPlaying,
		{x.set(\rq, qual)}
	);
});

~button = Button(w, Rect(430,20,50,30))
.states_([
	["OFF", Color.black, Color.gray(0.8)],
	["ON", Color.white, Color(0.2,0.75,0.95)]
])
.font_(Font("Monaco", 18))
.action_({
	arg obj;
	if(
		obj.value == 1,
		{
			x = Synth(
				\simplebpf,
				[
					\freq,
					~slider.value.linexp(0,1,100,4000),
					\rq,
					~knob.value.linexp(0,1,1,100).reciprocal
				]
		).register},
		{x.free}
	);
});
)

Another object I use very often is called StaticText, which is ideal for simply labeling your objects with text. So I'm going to put a frequency label directly below the number box. String is probably the most important attribute, which determines the text that'll be displayed. I'll keep the typeface consistent. And here's a new method-- you can align the text within the object's bounds by providing a symbol -- usually either \left, \right, or \center. Background we've seen before, and the text color is specified with message stringColor.

(
Window.closeAll;
w = Window("gui", Rect(750,50,500,200))
.front
.alwaysOnTop_(true);

~slider = Slider(w, Rect(20,20,150,30))
.background_(Color(0.2,0.75,0.95))
.action_({
	arg obj;
	var cf;
	cf = obj.value.linexp(0,1,100,4000).postln;
	if(
		x.isPlaying,
		{x.set(\freq, cf)}
	);
	~numberBox.value_(obj.value.linexp(0,1,100,4000));
});

~numberBox = NumberBox(w, Rect(180,20,80,30))
.value_(100)
.clipLo_(100)
.clipHi_(4000)
.font_(Font("Monaco", 16))
.decimals_(2)
.action_({
	arg obj;
	~slider.valueAction_(obj.value.explin(100,4000,0,1))
});

~freqLabel = StaticText(w, Rect(180,50,80,20))
.string_("freq")
.font_(Font("Monaco", 14))
.align_(\center)
.background_(Color.white) //remove these two later
.stringColor_(Color.red);

~knob = Knob(w, Rect(270,20,30,30))
.action_({
	arg obj;
	var qual;
	qual = obj.value.linexp(0,1,1,100).reciprocal;
	if(
		x.isPlaying,
		{x.set(\rq, qual)}
	);
});

~button = Button(w, Rect(430,20,50,30))
.states_([
	["OFF", Color.black, Color.gray(0.8)],
	["ON", Color.white, Color(0.2,0.75,0.95)]
])
.font_(Font("Monaco", 18))
.action_({
	arg obj;
	if(
		obj.value == 1,
		{
			x = Synth(
				\simplebpf,
				[
					\freq,
					~slider.value.linexp(0,1,100,4000),
					\rq,
					~knob.value.linexp(0,1,1,100).reciprocal
				]
		).register},
		{x.free}
	);
});
)

If we don't specify colors, the text defaults to black, and the background is fully transparent. Usually I prefer this default look, but I might start with an opaque background so I can actually see the boundaries of the text object, and thet later I'll make it transparent when I'm all done positioning everything.

(
Window.closeAll;
w = Window("gui", Rect(750,50,500,200))
.front
.alwaysOnTop_(true);

~slider = Slider(w, Rect(20,20,150,30))
.background_(Color(0.2,0.75,0.95))
.action_({
	arg obj;
	var cf;
	cf = obj.value.linexp(0,1,100,4000).postln;
	if(
		x.isPlaying,
		{x.set(\freq, cf)}
	);
	~numberBox.value_(obj.value.linexp(0,1,100,4000));
});

~numberBox = NumberBox(w, Rect(180,20,80,30))
.value_(100)
.clipLo_(100)
.clipHi_(4000)
.font_(Font("Monaco", 16))
.decimals_(2)
.action_({
	arg obj;
	~slider.valueAction_(obj.value.explin(100,4000,0,1))
});

~freqLabel = StaticText(w, Rect(180,50,80,20))
.string_("freq")
.font_(Font("Monaco", 14))
.align_(\center);

~knob = Knob(w, Rect(270,20,30,30))
.action_({
	arg obj;
	var qual;
	qual = obj.value.linexp(0,1,1,100).reciprocal;
	if(
		x.isPlaying,
		{x.set(\rq, qual)}
	);
});

~button = Button(w, Rect(430,20,50,30))
.states_([
	["OFF", Color.black, Color.gray(0.8)],
	["ON", Color.white, Color(0.2,0.75,0.95)]
])
.font_(Font("Monaco", 18))
.action_({
	arg obj;
	if(
		obj.value == 1,
		{
			x = Synth(
				\simplebpf,
				[
					\freq,
					~slider.value.linexp(0,1,100,4000),
					\rq,
					~knob.value.linexp(0,1,1,100).reciprocal
				]
		).register},
		{x.free}
	);
});
)

Lets briefly talk about focusing. By default, some GUI objects are allowed to be in focus, and only one object can be in focus at a given time. If I bring the window into focus and repeatedly press tab, you should be able to see that I'm cycling focus through these four objects, in the order I've created them-- StaticText is the one exception here, which by default cannot be in focus. And you might even be able to see the faint blue outline that signifies when an object is in focus. Another way to focus a particular object, assuming it can focus, is to just click directly on it.

When an object is in focus, certain default key actions are available. For example, let's focus the slider. pressing c puts the slider at its center position, x at its maximum, n at its minimum, and r chooses a random value. These four key actions also apply to the knob. The arrow keys often have actions associated with them, usually incrementing or decrementing the object. And modifier keys like alt and shift will often modify the arrow key or mouse behavior. I discovered a lot of these default key actions by accident, so I encourage you to mess around to see what's actually possible. And, when a button is in focus, pressing spacebar does the same thing as clicking with the mouse.

Ok, so I can't show every GUI object, that'd be ridiculous. But let me at least point out the objects that I use more often than most.

PopUpMenu gives a drop-down list of items, very similar to the Mac OS drop-down menus at the top of the screen here.
(
~obj.remove;
~obj = PopUpMenu(w, Rect(20,100,120,30))
.items_(["", "one", "two", "three"])
)
RangeSlider is similar to Slider but instead of one value, has a minimum and maximum value that are independent of each other.
(
~obj.remove;
~obj = RangeSlider(w, Rect(20,100,120,30))
)

TextField is a one-line text entry box
(
~obj.remove;
~obj = TextField(w, Rect(20,100,120,30))
)

TextView is similar, but allows multiple lines of text
(
~obj.remove;
~obj = TextView(w, Rect(20,100,120,80))
)

Slider2D is a two-dimensional slider, pretty self-explanatory
(
~obj.remove;
~obj = Slider2D(w, Rect(20,100,120,80))
)

and MultiSliderView, again the name is pretty self-explanatory
(
~obj.remove;
~obj = MultiSliderView(w, Rect(20,100,120,80))
.size_(9)
)

~obj.remove;

And there are two others, SoundFileView, this is a multi-featured object which is primarily used to display an audio waveform, and LevelIndicator, which, actually these objects on the meter window are all LevelIndicators. Again, see the help files for examples of how these objects work.

Ok so the last thing I'd like to cover has to do with workflow and efficiency. Now, something that really seems to turn people off from building graphical interfaces in SuperCollider is the sort of, you know, tedious, pixel-hunting aspects. Now I've been dropping objects onto my window pretty quickly, but of course I've prepared for this video, so I'm sort of cheating. Now in SuperCollider, there's no native drag and drop environment for interface design, of course that's not to say you couldn't build such a thing yourself, in fact, maybe some people already have. And unless you've been blessed with godlike programming abilities, it's hard to deny that interface design is just faster and more intuitive in something like Pd or Max/MSP, and well that's just the nature of how these environments are designed. Ultimately, if you're building an interface in SuperCollider, either it's gonna take some time and you're going to have to do some degree of pixel-hunting, or you just have be ok with sloppy GUIs. Or, there's the option that I prefer, which is planning things out in advance the old fashioned way, with pencil and graph paper. But there are tricks and features that can speed things up quite a bit.

One thing I've been doing already that you might have noticed is to put Window.closeAll at the top of my primary clump of code. This prevents windows from piling up after multiple evaluatons, which automatically avoids unnecessary clutter. With all the GUI code in a single executable clump, I can make changes and then see those changes almost immediately. Like, uh, let's say I want to move the button so it's right next to the knob, and then tidy up the window so I don't have all this extra space. I don't know the exact pixel values, but I can mess around until it looks right...so we'll shift the button to the left...and now adjust the window size...

(
Window.closeAll;
w = Window("gui", Rect(850,50,380,80))
.front
.alwaysOnTop_(true);

~slider = Slider(w, Rect(20,20,150,30))
.background_(Color(0.2,0.75,0.95))
.action_({
	arg obj;
	var cf;
	cf = obj.value.linexp(0,1,100,4000).postln;
	if(
		x.isPlaying,
		{x.set(\freq, cf)}
	);
	~numberBox.value_(obj.value.linexp(0,1,100,4000));
});

~numberBox = NumberBox(w, Rect(180,20,80,30))
.value_(100)
.clipLo_(100)
.clipHi_(4000)
.font_(Font("Monaco", 16))
.decimals_(2)
.action_({
	arg obj;
	~slider.valueAction_(obj.value.explin(100,4000,0,1))
});

~freqLabel = StaticText(w, Rect(180,50,80,20))
.string_("freq")
.font_(Font("Monaco", 14))
.align_(\center);

~knob = Knob(w, Rect(270,20,30,30))
.action_({
	arg obj;
	var qual;
	qual = obj.value.linexp(0,1,1,100).reciprocal;
	if(
		x.isPlaying,
		{x.set(\rq, qual)}
	);
});

~button = Button(w, Rect(310,20,50,30))
.states_([
	["OFF", Color.black, Color.gray(0.8)],
	["ON", Color.white, Color(0.2,0.75,0.95)]
])
.font_(Font("Monaco", 18))
.action_({
	arg obj;
	if(
		obj.value == 1,
		{
			x = Synth(
				\simplebpf,
				[
					\freq,
					~slider.value.linexp(0,1,100,4000),
					\rq,
					~knob.value.linexp(0,1,1,100).reciprocal
				]
		).register},
		{x.free}
	);
});
)

There, that looks nice and tidy. Now maybe this technique isn't quite as handy as drag-and-drop, but really, it's not bad, and not all that slow either. And with a little practice, this approach becomes pretty intuitive.

But the real breadwinner when it comes to efficiency is the concept of decorators. A decorator can be assigned to a parent view, and will govern how and where child views are positioned on it. As far as I know, there's currently only one type of decorator, called FlowLayout. And to show how FlowLayout works, I'm going to create a new Window, and introduce a few other concepts along the way.

Here's our window. And then, we assign an instance of FlowLayout as the decorator of the main view. FlowLayout takes three arguments. The first is an instance of Rect to determine the bounds of the decorator, and in pretty much every case, you'll want to apply this decorator to the entire parent view area, so we can just specify the bounds of the window itself. For the second and third argument, we provide instances of a class called Point, which is an abstract representation of a point on the cartesian plane. The 2nd argument here is the margin, which establishes a border, measured in pixels, between the child views and the edges of the parent space. The third argument is the gap, which determines the vertical and horizontal pixel space between adjacent child views. Let's say a 15x15 pixel margin around the window, and the child views will be separated from their neighbors by seven pixels, horizontally and vertically.

And there's actually a very nice syntax shortcut for Point, which is simply x@y. So we can make these last two arguments much more compact.

(
Window.closeAll;
w = Window.new("flow", Rect(850,50,400,400))
.front
.alwaysOnTop_(true);

w.view.decorator_(FlowLayout(w.bounds, 15@15, 7@7));
)

Now, the fun part. Let's put a knob on the window. Previously, we had to specify an instance of rect for the object's bounds. but now, relying on FlowLayout, we only need to provide an instance of point, which determines the width and height of the object.

Knob(w, 40@40);

Ok, not that impressive, but let's run this line again several times.

Knob(w, 40@40);

FlowLayout essentially turns the parent view into a multi-line text field, but instead of text characters, we're dealing with GUI objects. FlowLayout simply puts the next object to the right of the previous one, and goes to the next line when it runs out of horizontal space. And FlowLayout is pretty smart about collisions, in case the objects are not all the same size:

Knob(w, 80@80);
Knob(w, 40@40);

We can force a new line by using the nextLine method on the instance of FlowLayout:

w.view.decorator.nextLine;
Knob(w, 40@40);

And we can use iteration to add many objects at once
20.do{Knob(w,40@40)};


Notice there's a 15x15 border around the objects, and that the knobs are spaced 7 pixels away from one another in horizontal and vertical directions. Here's iteration to manipulate many objects at once-- in this case I'm randomizing the value of every child view
w.view.children.collect(_.value_(rrand(0.0,1.0)));

And iteration to remove multiple objects.
w.view.children.collect(_.remove);

Adding more objects at this point will continue to defer to the decorator for xy positioning-- the object doesn't appear in the upper left corner like you might expect
Knob(w, 40@40);

so we can use the reset message on the decorator to start over.
w.view.decorator.reset;
Knob(w, 40@40);

That's the essence of FlowLayout, but this example is a little fast and loose, so I just want to show one more example and introducte the concept of subviews and nested layouts. So, It's often a good idea, when you're designing an interface, to compartmentalize the various functionalities, and then have the GUI reflect these conceptual divisions. For example, if you're designing some sort of synthesizer, you might have an oscillator section, a noise generator section, a filter section, and so forth. But each of these sections is probably going to contain multiple GUI objects, so it's nice to be able to refer to one specific collection of GUI objects, instead of having to refer to everything at once, or refer to objects one at a time. For this purpose there are a couple objects that simply behave as parent views on which you can place more objects, One of these is called CompositeView, which I use fairly often to establish a more meaningful hierarchy within the design of the interface.

So in the following example, we have a window, and I'm assigning a FlowLayout to govern the placement of all immediate children, with a 30x30 margin and gap. And then I'm going to fill an Array with four composite views, placed on this main view, each with a random background color. And each of these four subviews is going to get its own instance of flowlayout with a 5x5 margin and gap.

(
Window.closeAll;
w = Window.new("nested views", Rect(750,50,500,500))
.front
.alwaysOnTop_(true);

w.view.decorator_(FlowLayout(w.bounds, 30@30, 30@30));

c = Array.fill(4, {
	arg view;
	view = CompositeView(w, 200@200)
	.background_(Color.rand);
	view.decorator_(FlowLayout(view.bounds,5@5,5@5));
});
)

Let's say this upper left composite view will be my slider section. So again, for the purposes of convenient storage and access, I'll fill another Array, this time with 5 sliders. And becasue I've stored my composite views in an array named c, I can easily refer to these views, in this case the upper left composite view is stored at index zero.


(
Window.closeAll;
w = Window.new("nested views", Rect(750,50,500,500))
.front
.alwaysOnTop_(true);

w.view.decorator_(FlowLayout(w.bounds, 30@30, 30@30));

c = Array.fill(4, {
	arg view;
	view = CompositeView(w, 200@200)
	.background_(Color.rand);
	view.decorator_(FlowLayout(view.bounds,5@5,5@5));
});

Array.fill(5, {Slider(c[0], 30@150)});
)

And let's put 8 knobs on the next composite view.

(
Window.closeAll;
w = Window.new("nested views", Rect(750,50,500,500))
.front
.alwaysOnTop_(true);

w.view.decorator_(FlowLayout(w.bounds, 30@30, 30@30));

c = Array.fill(4, {
	arg view;
	view = CompositeView(w, 200@200)
	.background_(Color.rand);
	view.decorator_(FlowLayout(view.bounds,5@5,5@5));
});

Array.fill(5, {Slider(c[0], 30@150)});
Array.fill(8, {Knob(c[1], 40@40)});
)

And, because we've stored these objects in Arrays, it's actually very easy to refer to a specific object, for example, within the upper left composite view, let's access the middle slider, which is at index 2, and set its value to 0.5.

c[0].children[2].value_(0.5);

Likewise, we can easily access all of the knobs simultaneously, like this:
c[1].children.collect(_.value_(0.75));

If you're following along, you might want to try to add more objects to the composite views on the lower half of the window. And also, you might prefer to use another collection type class, like Dictionary, in case you want to refer to GUI objects by a symbolic name instead of an ordered integer index.

But in any case, I hope this last example demonstrates that you can create and easily access many GUI objects, without having to type hundreds of lines of code.

That's all for tutorial 14. I hope this tutorial helps to demystify the process of building a graphical user interface in SuperCollider. I'm considering the possibility of returning to this topic in a future video to focus on building something a bit more involved and hopefully more practical as well. But in the meantime, please feel free to leave any comments or questions. And as always, thanks so much for watching, and see you next time.
