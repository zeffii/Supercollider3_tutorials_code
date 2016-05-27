13_script

Hey everybody, welcome to tutorial 13. This'll be the third and final installment on OSC. In this video I'll be showing how to use the XBox Kinect Sensor to manipulate sound in real-time.

There's a variety of software out there designed to translate motion data from the Kinect into OSC messages. You can check out the video description below for a few links and resources. For this tutorial, I'm going to be using a program called Synapse, developed by Ryan Challinor. I'm not claiming Synapse is objectively the best option, but it's the one I understand most clearly, it's simple, it's free, and it works right out of the box. In this video I'm on Mac 10.8.5, but keep in mind that what you see in this tutorial might not work for your setup at home, and if that's the case, the reality is that you just might have to do some research on your own. It's impractical for me to cover all the different options in these videos, but my hope is that what you do see in these tutorials will at least give you a push in the right direction.

So the first thing you want to do, is make sure your Kinect sensor bar is powered, and also plugged into your computer via USB. Then, download and install Synapse, which at the time of making this video, is available at synapsekinect.tumblr.com. Once installed, open Synapse, and this is what you'll see.

So, since we're here, let's get Synapse to start tracking my skeleton. To do this, you'll need to stand squarely facing the camera, elbows out, forearms up, and sometimes I find it helps to puff out your chest a bit. Sometimes it takes a few seconds, but, obviously synapse has found me. The kinect conceives of the human form as a skeleton made up of a collection of joints. Head, torso, two hands, elbows, shoulders, hips, knees, and feet.

That's about all we can do with Synapse for now, so let's open up SuperCollider and start preparing to receive data from the kinect.

First, we boot the server,

s.boot;

And what we need to do is create some object in SuperCollider which represents Synapse, so that we can send messages to it. But first we need to talk about how Synapse works. You can, in fact, find these details on the tumblr page, on the section labeled MaxMSP/Jitter. This is how I learned it myself, and I absolutely encourage you to read all about it too.

receives on 12346
sends on 12345 and 12347

Synapse receives OSC messages on port 12346, and sends messages on ports 12345 and 12347. These two send ports are identical, so it doesn't matter which one you use. As for IP address, most likely you'll be using Synapse and SuperCollider on the same computer, in which case you should use the loopback address 127.0.0.1.

So now we can take the next step. I'm going create an instance of a class called NetAddr, which represents a destination for OSC messages, represented by an IP address, specified as a string, and a port number, specified as an integer.

~synapse = NetAddr.new("127.0.0.1", 12346);

So now the question is, what kinds of messages can we send to synapse? On the tumblr page, Ryan provides a list of valid incoming messages, each accompanied by a description of what that message does. For now I'm going to focus on perhaps the most useful one, which is how to track the position of a particular joint. And the address of this message is slash, the name of a joint, taken from this list here, underscore, trackjointpos. This address is followed by one integer, which determines the system of joint measurement. If this integer is 1, joint positions are measured in milimeters relative to the torso. If 2, the kinect sees itself as the origin of threespace, and joints are measured in millimeters relative to the kinect. And 3 is pixels on the synapse window, which I believe is always 640x480.

~synapse.sendMsg("/righthand_trackjointpos", 2);

So an example message might look like this. Here, we request the xyz coordinates of the right hand in world space. But this is only half the equation. So the question now is: what does Synapse do in response to one of these requests? Well here's what happens: when Synapse receives a message to track a joint, it outputs a continuous stream of xyz position values, for only about 3 or 4 seconds, then stops. Sending the same message again a few seconds later will keep the stream alive for a few more seconds. It's done this way for efficiency reasons. One of the main alternatives to this design choice would be to have synapse spew out data for every joint, all the time, and this would just be a torrential flood of data, and there'd be a higher risk of osc messages getting dropped.

So here's an OSCdef which will receive position data for my right hand. For now, we'll just print the raw OSC message being sent from synapse. The third argument is the OSC address of the incoming messages, and here let's briefly jump back to the tumblr page, where we can see the list of messages which Synapse sends.

Now, since I'm choosing option 2 in the outgoing message to Synapse, this means I am requesting the position of the right hand in world space, and so I should expect to receive messages with the address slash, righthand underscore pos underscore world. Fourth is source ID, which I'm going to ignore, and fifth is the port number, which, as mentioned earlier, can be either 12345 or 12347.

(
OSCdef.new(
	\trackRH,
	{
		arg msg;
		msg.postln;
	},
	'/righthand_pos_world',
	nil,
	12345
);
)

So, evaluate this OSCdef, and now if we were to send this message to Synapse, we should see, in return, a stream of xyz position data dumped into the post window, for about 3 seconds or so. First I just want to make sure Synapse is still tracking me...looks like we're good...

~synapse.sendMsg("/righthand_trackjointpos", 2);

We see a stream of xyz coordinates for the position of my right hand. And as expected, the stream stops after a few seconds. So the next step is to construct something in SuperCollider which sends this OSC message to Synapse at regular intervals. And something like this is probably best handled by one of two classes - Task and Routine. And in most cases, especially for something as simple as this, you can use either one. Both of these objects take a function, and turn it into a process that can be started and stopped, and the user can specify wait times at points throughout the function.

So I'm gonna use Task, first we send the OSC message to synapse. And then we wait for 2 seconds. But of course, we want to repeat these two actions indefinitely, in order to receive an ongoing, continuous stream of data. So we enclose these two steps in curly braces, and append dot-loop.

(
~trackRH = Task.new({
	~synapse.sendMsg("/righthand_trackjointpos", 2);
	2.wait;
}).play;
)

And without further ado, let's play this Task.

(
~trackRH = Task.new({
	{
		~synapse.sendMsg("/righthand_trackjointpos", 2);
		2.wait;
	}.loop;
}).play;
)

...and data flows into SuperCollider with reckless abandon. Uh. Ok so it's difficult to tell what the hell's actually going on here, so let me resize the post window. And let's confirm that things are going as expected. You can see that my right hand is near the center of the screen, and x and y position values are close to zero, and this means my hand is very close to the z axis, which is the depth axis. And my hand is about a meter from the Kinect. Now take a look at the first value, which is distance along the horizontal x axis...the second value for the vertical y axis, and the third value, which is depth along the z axis.

Ok, so we're in good shape.

(
OSCdef(\trackRH).free;
~trackRH.stop;
)

Let's say we want to use one of the other systems of measurement. If I wanted joint positions measured relative to the torso, I'd specify 1 as the outgoing argument, and in return, I'd receive messages from the address slash righthand underscore pos underscore body. And for pixels on screen, option 3, receivng on slash right hand underscore pos underscore screen.

In pixel mode, x values are 0 on the left border, 640 on the right, y values are 0 at the top, and 480 at the bottom, and, well wait a minute, how is synapse generating depth values from pixels on screen? Well, the short answer is, it's...not doing that, because that wouldn't make any sense. In pixel mode, Synapse sends depth values as if it were actually in world mode, so z values here represent distance from the kinct, in millimeters.

(
OSCdef.freeAll;
~trackRH.stop;
)

One more thing before we start making sound. In addition to receiving continuous position data, we can also receive so-called "hit" triggers, and there are six different types for each joint. As we can see on the tumblr page, there's up, down, left, right, forward, and back, two directions for each axis. And looking at Synapse, we can see that each joint includes six black rectagles. When we trigger a hit in one of these directions, the corresponding rectangle flashes green. For example, with my right hand, here are some up hits... right hits... and so forth. So let's take a look at how we can receive and use these hit events.

The outgoing messages don't really change. We still need to track the joint, but the system of measurement we choose doesn't matter, because these hit events aren't measured according to length or distance or anything, they're just instantaneous triggers. For the OSCdef, I'll leave the function as is, so we're still just printing the incoming message, but the address needs to be changed to, simply, a slash, followed by the name of the joint.

So now, when we receive a hit event, SuperCollider will post the incoming message, which contains the address, and a single argument, which is a symbol representing the type of hit.

(
~trackRH = Task.new({
	{
		~synapse.sendMsg("/righthand_trackjointpos", 2);
		2.wait;
	}.loop
}).play;

OSCdef.new(
	\trackRH,
	{
		arg msg;
		msg.postln;
	},
	'/righthand',
	nil,
	12345
);
)

Up, right, left, forward... you get the idea.

You may find that you may want to calibrate the sensitivity of how these hits are detected. This is done using some combination of two messages, required length, and point history size, and these two parameters are applied to joints on a individual basis. Required length is the distance in millimeters the joint must move in order to trigger a hit, and point history size is the number of data points, which I think equates to the number of video frames, that are used to analyzing whether a joint has covered enough distance to trigger a hit.

So for example, if I set required length to 20, and point history size to 60, this means I only have to move my right hand 20 mm within 60 frames in order to trigger a hit. In effect, this greatly increases the system's sensitivity to hit events.

~synapse.sendMsg("/righthand_requiredlength", 20.0);
~synapse.sendMsg("/righthand_pointhistorysize", 60);

And you can see that all i have to do is flick my wrist around to generate a bunch of hits.

As required length gets larger and point history size gets smaller, the sensitivy of the system is greatly reduced. So with settings like this, for example, i can flail around like crazy, but as you can see, synapse is just not interested in anything I'm doing.

~synapse.sendMsg("/righthand_requiredlength", 250.0);
~synapse.sendMsg("/righthand_pointhistorysize", 4);

A quick word of warning here. Synapse insists that required length MUST be a floating point number, and point history size MUST be an integer. And unlike SuperCollider, Synapse is very unforgiving of mistakes like this. For example I were to just nonchalantly set required length to the integer 250, without the point zero, actually, synapse would crash immediately. So, consider yourself advised, always read the manual, etc. Ok so, I'm going to return these calibration values to their defaults, and get rid of our Task and OSCdef. Now it's time to make some sound.

(
~synapse.sendMsg("/righthand_requiredlength", 150.0);
~synapse.sendMsg("/righthand_pointhistorysize", 5);
OSCdef.freeAll;
~trackRH.stop;
)

We'll start with something simple. I want to send some PinkNoise through a bandpass filter, and control the center frequency of the filter according to the horizontal position of my right hand. So here I'm just creating a simple Synth and calling it noise. I'm going to lag the frequency values by a 20th of a second, because this will help to smooth out the incoming data, in case there are any hiccups or sudden changes. I'm gonna use option 3 to request pixel mode, and in the OSCdef, I'm going to set the frequency argument based on the x position. Remember that the incoming OSC message is an array, and the 0th item is the incoming address. But we want the first numerical argument, which is horizontal position, so we say msg[1]. But we don't want the raw pixel value, so I'm going to use linexp to map this range onto a different range which is suitable for a cutoff frequency. Lets say 100 Hz to 3kHz.

And remarkably, this ought to be everything we need.

(
~noise = {
	arg freq=440, gate=1;
	var sig;
	sig = PinkNoise.ar(1!2);
	sig = BPF.ar(sig, freq.lag(0.05), 0.3);
	sig = sig * EnvGen.kr(Env.adsr(5,0,1,2,1,1),gate,doneAction:2);
}.play;

~trackRH = Task.new({
	{
		~synapse.sendMsg("/righthand_trackjointpos", 3);
		2.wait;
	}.loop;
}).play;

OSCdef.new(
	\trackRH,
	{
		arg msg;
		~noise.set(\freq, msg[1].linexp(0,640,100,3000).postln);
	},
	'/righthand_pos_screen',
	nil,
	12345
);
)

(
~noise.set(\gate, 0);
OSCdef.freeAll;
~trackRH.stop;
)

Let's make some modifications. For example, let's use the vertical position of the right hand to control amplitude. First a new argument for the source sound, which I will also lag. Then, we make sure the OSCdef controls the amplitude argument in addition to the frequency argument. I'm gonna map the raw pixel data to decibels, so zero decibels at the top of the screen, and -40 dB at the bottom, making sure, of course to convert from decibels to amplitude, because that's what the noise synth expects.

(
~noise = {
	arg freq=440, gate=1, amp=0;
	var sig;
	sig = PinkNoise.ar(1!2);
	sig = BPF.ar(sig, freq.lag(0.05), 0.3);
	sig = sig * amp.lag(0.05);
	sig = sig * EnvGen.kr(Env.adsr(5,0,1,2,1,1),gate,doneAction:2);
}.play;

~trackRH = Task.new({
	{
		~synapse.sendMsg("/righthand_trackjointpos", 3);
		2.wait;
	}.loop;
}).play;

OSCdef.new(
	\trackRH,
	{
		arg msg;
		~noise.set(
			\freq, msg[1].linexp(0,640,100,3000),
			\amp, msg[2].linlin(0,480,0,-40).postln.dbamp
		);
	},
	'/righthand_pos_screen',
	nil,
	12345
);
)

(
~noise.set(\gate, 0);
OSCdef.freeAll;
~trackRH.stop;
)

Let's use a forward hit to free the Synth when I'm done with it, rather than doing so by evaluating code. For this we'll need a second OSCdef, with a different name, and the address should just be slash right hand. And what we want here is a conditional statement which asks, is the incoming message a forward hit? If so, set the gate to zero. And for good measure, print the message to the post window.

(
~noise = {
	arg freq=440, gate=1, amp=0;
	var sig;
	sig = PinkNoise.ar(amp.lag(0.05)!2);
	sig = BPF.ar(sig, freq.lag(0.05), 0.3);
	sig = sig * EnvGen.kr(Env.adsr(5,0,1,2,1,1),gate,doneAction:2);
}.play;

~trackRH = Task.new({
	{
		~synapse.sendMsg("/righthand_trackjointpos", 3);
		2.wait;
	}.loop;
}).play;

OSCdef.new(
	\trackRH,
	{
		arg msg;
		~noise.set(
			\freq, msg[1].linexp(0,640,100,3000),
			\amp, msg[2].linlin(0,480,0,-40).dbamp
		);
	},
	'/righthand_pos_screen',
	nil,
	12345
);

OSCdef.new(
	\trackRHhit,
	{
		arg msg;
		msg[1].postln;
		if(
			msg[1] == \forward,
			{~noise.set(\gate, 0)}
		);
	},
	'/righthand',
	nil,
	12345
);
)

(
~noise.set(\gate, 0);
OSCdef.freeAll;
~trackRH.stop;
)

Punch forward, and the sound fades. Ok so SuperCollider is complaining about something, specifically, the OSCdefs are still active, and they're trying...and failing to use position data to set arguments to a Synth that no longer exists. And you know, we probably don't really want ugly failure messages pouring into the post window, so the first solution that comes to my mind is to make a Group... put the Synth inside the group, and instead of having the OSCdef talk directly to a Synth which may or may not exist, they'll communicate with the enclosing group, which is gonna stay put right where it is. Another benefit of using a Group is that we don't need to give the Synth a name anymore.

(
g = Group.new;

{
	arg freq=440, gate=1, amp=0;
	var sig;
	sig = PinkNoise.ar(amp.lag(0.05)!2);
	sig = BPF.ar(sig, freq.lag(0.05), 0.3);
	sig = sig * EnvGen.kr(Env.adsr(5,0,1,2,1,1),gate,doneAction:2);
}.play(g);

~trackRH = Task.new({
	{
		~synapse.sendMsg("/righthand_trackjointpos", 3);
		2.wait;
	}.loop;
}).play;

OSCdef.new(
	\trackRH,
	{
		arg msg;
		g.set(
			\freq, msg[1].linexp(0,640,100,3000),
			\amp, msg[2].linlin(0,480,0,-40).dbamp
		);
	},
	'/righthand_pos_screen',
	nil,
	12345
);

OSCdef.new(
	\trackRHhit,
	{
		arg msg;
		msg[1].postln;
		if(
			msg[1] == \forward,
			{g.set(\gate, 0)}
		);
	},
	'/righthand',
	nil,
	12345
);
)

(
OSCdef.freeAll;
~trackRH.clear;
)

Punch forward, and the sound fades, and no error messages. So now could even use a different type of hit event to create a Synth. We'll keep the forward hit as is, and let's say a back hit from the right hand adds a synth to the group. So we just move this code into the OSCdef. I'll also shorten the attack and release times to make the sound more audible.

(
g = Group.new;

~trackRH = Task.new({
	{
		~synapse.sendMsg("/righthand_trackjointpos", 3);
		2.wait;
	}.loop;
}).play;

OSCdef.new(
	\trackRH,
	{
		arg msg;
		g.set(
			\freq, msg[1].linexp(0,640,100,3000),
			\amp, msg[2].linlin(0,480,0,-40).dbamp
		);
	},
	'/righthand_pos_screen',
	nil,
	12345
);

OSCdef.new(
	\trackRHhit,
	{
		arg msg;
		msg[1].postln;
		if(
			msg[1] == \forward,
			{g.set(\gate, 0)}
		);
		if(
			msg[1] == \back,
			{
				{
					arg freq=440, gate=1, amp=0;
					var sig;
					sig = PinkNoise.ar(amp.lag(0.05)!2);
					sig = BPF.ar(sig, freq.lag(0.05), 0.3);
					sig = sig * EnvGen.kr(Env.adsr(0.05,0,1,0.05,1,1),gate,doneAction:2);
				}.play(g);
			}
		);
	},
	'/righthand',
	nil,
	12345
);
)

(
OSCdef.freeAll;
~trackRH.stop;
)

Right, so, hopefully this gives you a basic understanding. I want close out this video with a more complex example. As always, I encourage you to pause the video wherever you find the need so you can copy the code or just study what I'm doing here at a more leisurely pace. So here's an overview of what I'm going to do. I'm gonna use patterns to granulate two sound files, and i'll control one sound with my left hand, and another with my right hand. In addition, whenever I get a forward hit from either hand, I'll send the granulation through a delay effect for a few seconds. So first I'm going to need two sound files loaded into buffers. I have prepared for this tutorial with the sound of a motorcycle trying to start...and rubbing the rim of a wine glass with a lot of pressure. I'm also going to need two SynthDefs, one to play a single short segment of a sound file, because the actual granulation effect will be handled later by patterns, and another synthdef for the delay effect. Now to save time I'm gonna do something I haven't done before. I'm actually just gonna paste these SynthDefs into the editor, rather than typing them in. So again, pause the video if you need to, and I hope this doesn't break the flow of the video too much. The first SynthDef plays some portion of a sound file, with specified transposition, start position, and pan position. I'm using midiratio to convert from semitones into a frequency ratio, and there's a variable-length envelope which controls the amplitude of the sound. The second SynthDef controls the delay effect. So I use In.ar to read the incoming signal, and I store it in two different variables. I leave sig alone and only process the one called fx, so I can later mix between the two of them. fx is sent through three comb filters, in series, with uniqely meandering delay times. This envelope called mix, is not controlling amplitude, rather it's being used to crossfade between the unprocessed and processed signal. At rest position, the envelope has a value of -0.9, so the output of XFade2 is almost entirely the raw input signal calle sig. When the envelope is triggered by t_fxtrig, the envelope quickly jumps up to 0.75, so we immediately hear lots of the comb filter effect, and we crossfade back to the unprocessed signal over 5 seconds. Notice there's no doneAction:2 on this envelope, because I want to be able to trigger it multiple times. Since I'm passing a stereo signal between these Synths, I'll need a two channel audio bus, and to keep things organized, I'm also going to make two groups. One for the generated grains, and another group immediately after the first, for the delay effect synth.

(
~engine = Buffer.read(s,"/Users/eli/Desktop/sounds/engineStart.aiff");
~glass = Buffer.read(s,"/Users/eli/Desktop/sounds/glassRub.aiff");

SynthDef.new(\grain, {
	arg buf=0, trnsp=0, spos=0, atk=0.01, sus=0.03, rel=0.01, pan=0, amp=1, out=0;
	var sig, env;
	sig = PlayBuf.ar(1,buf,BufRateScale.ir(buf)*trnsp.midiratio, startPos:spos, doneAction:2);
	sig = Pan2.ar(sig,pan,amp);
	env = EnvGen.kr(Env.new([0,1,1,0],[atk,sus,rel],[1,0,-1]),doneAction:2);
	sig = sig * env;
	Out.ar(out,sig);
}).add;

SynthDef.new(\echo, {
	arg in, t_fxtrig=0, out=0;
	var sig, fx, mix;
	sig = In.ar(in,2);
	fx = In.ar(in,2);
	3.do{fx = CombL.ar(fx, 0.25, LFNoise1.kr(0.05).range(0.04,0.25), 4, 0.65)};
	mix = EnvGen.kr(Env.new([-0.9,0.75,-0.9],[0.1,5],\lin),t_fxtrig);
	sig = XFade2.ar(sig, fx, mix);
	Out.ar(out,sig);
}).add;

~fxbus = Bus.audio(s,2);
~grainGrp = Group.new;
~fxGrp = Group.after(~grainGrp);
)

Alright, moving on, now I'm going to deal with the patterns. Again just gonna paste these in, pause the video at your discretion. Now currently, these patterns are pretty simple, the parameters are either fixed, like the sound file, group, and output bus, and the rest of them are just controlled randomly, with either pwhite or pexprand. So in their current state, these patterns are basically autonomous, and we don't yet have the option to change value streams in real time. I'm doing it this way so you get a sense of what these patterns sound like, before we start incorporating the kinect.

The Synths created by these two Pbinds are sending their output signal to the effects bus, so we need to make sure we have also created our delay effect Synth, reading from the appropriate bus, and that the Synth is placed in the appropriate group.

(
~enginePat = Pbind(
	\instrument, \grain,
	\dur, Pexprand(0.01,0.2),
	\buf, ~engine.bufnum,
	\sus, Pexprand(0.01,0.1),
	\trnsp, Pwhite(-3.0,3.0),
	\spos, Pwhite(0, ~engine.numFrames-1),
	\pan, Pwhite(-1.0,1.0),
	\amp, Pexprand(0.05,0.2),
	\group, ~grainGrp,
	\out, ~fxbus
);

~glassPat = Pbind(
	\instrument, \grain,
	\dur, Pexprand(0.01,0.2),
	\buf, ~glass.bufnum,
	\sus, Pexprand(0.01,0.1),
	\trnsp, Pwhite(-3.0,3.0),
	\spos, Pwhite(0, ~engine.numFrames-1),
	\pan, Pwhite(-1.0,1.0),
	\amp, Pexprand(0.1,0.25),
	\group, ~grainGrp,
	\out, ~fxbus
);

Synth.new(\echo, [\in, ~fxbus, \out, 0], ~fxGrp);
)

So here's the granulated engine...and the granulated wine glass
~engineStream = ~enginePat.play;
~glassStream = ~glassPat.play;

And if we trigger the delay effect...the sound is delayed with feedback, and the effect fades over about five seconds.

~fxGrp.set(\t_fxtrig, 1);

Ok so now we need to modify these patterns in such a way that we'll be able to change value streams without having to stop and restart the event stream players. You might remember from tutorial 10 that for this, we use Pdefn. So I'd like to use the xyz values of my hands to control several parameters: the time between grains, that'd be the dur pattern, pitch transposition, grain start position, and amplitude. Since these are all different parameters, I need to make sure the Pdefn symbols are all unique, and these initial Pdefn values I'm specifying are really just dummy values, because as soon as I start moving my hands around, these values are gonna start changing all over the place.

~engineStream.stop;
~glassStream.stop;

(
~enginePat = Pbind(
	\instrument, \grain,
	\dur, Pdefn(\durEngine, 0.1),
	\buf, ~engine.bufnum,
	\sus, Pexprand(0.01,0.1),
	\trnsp, Pdefn(\trnspEngine, Pwhite(0,0)),
	\spos, Pdefn(\sposEngine,0),
	\pan, Pwhite(-1.0,1.0),
	\amp, Pdefn(\ampEngine, 0.1),
	\out, ~fxbus
);

~glassPat = Pbind(
	\instrument, \grain,
	\dur, Pdefn(\durGlass, 0.1),
	\buf, ~glass.bufnum,
	\sus, Pexprand(0.01,0.1),
	\trnsp, Pdefn(\trnspGlass, Pwhite(0,0)),
	\spos, Pdefn(\sposGlass,0),
	\pan, Pwhite(-1.0,1.0),
	\amp, Pdefn(\ampGlass, 0.1),
	\out, ~fxbus
);

Synth.new(\echo, [\in, ~fxbus], ~fxGrp);
)

The final step is to include our Task and OSCdefs. The Task stays mostly the same, we just simply need to request data from both hands once every two seconds. But the OSCdefs will change quite a bit. I'll gonna need four OSCdefs in total: LH position, LH hits, RH position, and RH hits. The left hand will control the engine sound file, and the right hand will control the wine glass.

~trackHands = Task.new({
	{
		~synapse.sendMsg("/righthand_trackjointpos", 3);
		~synapse.sendMsg("/lefthand_trackjointpos", 3);
		2.wait;
	}.loop;
}).play;

Right, so whenever a position message comes in, the OSCdef will evaluate and therefore update several Pdefn patterns, whose values are determined by the incoming xyz position data. Grain start position will be determined by x position, so that as I move my hand from left to right, the grain pointer moves through the sound file from beginning to end. vertical position will control the time between grains, or grain density in other words. At the top of the screen, the dur pattern will output small time values, so we'll hear a dense cloud of grains, and when my hands are near the bottom, grains will be very sparse. The y value will also control the minimum possible amplitude. So a lower position on the screen means quieter grains. And the values along the depth axis will control transposition. As my hands move farther away from the kinect, the grains are transposed randomly within a wider and wider range, so when I'm 2.5 meters away or farther, grains can be transposed as many as 36 semitones in either direction.

OSCdef.new(
	\trackLHpos,
	{
		arg msg;
		Pdefn(\sposEngine, msg[1].linlin(0,640,0,~engine.numFrames-1));
		Pdefn(\durEngine, msg[2].linexp(0,480,0.002,1.5));
		Pdefn(\ampEngine, Pexprand(msg[2].linlin(0,480,-16,-36).dbamp,0.25));
		Pdefn(\trnspEngine, Pwhite(msg[3].linlin(800,2500,0,-36),msg[3].linlin(600,2500,0,36)));
	},
	'/lefthand_pos_screen',
	nil,
	12345
);

The corresponding OSCdef for the right hand will be almost exactly the same. I just need to change a few things. I need to give the OSCdef a unique name, supply the correct OSC address, change the Pdefn symbols, and also make sure we're referencing the other sound file.

OSCdef.new(
	\trackRHpos,
	{
		arg msg;
		Pdefn(\sposGlass,msg[1].linlin(0,640,0,~glass.numFrames-1));
		Pdefn(\durGlass, msg[2].linexp(0,480,0.002,1.5));
		Pdefn(\ampGlass, Pexprand(msg[2].linlin(0,480,-16,-36).dbamp,0.25));
		Pdefn(\trnspGlass, Pwhite(msg[3].linlin(800,2500,0,-36),msg[3].linlin(600,2500,0,36)));
	},
	'/righthand_pos_screen',
	nil,
	12345
);

And last, two OSCdefs to track hit events from each hand. Simply, when a forward hit is received, trigger the delay effect. Again, these two OSCdefs are almost identical; I just need to make sure their names are unique, and make sure they're listening on the appropriate addresses. So with these two, it doesn't matter which hand delivers a forward hit. Either one will trigger the effect.

OSCdef.new(
	\trackLHhit,
	{
		arg msg;
		if(
			msg[1] == \forward,
			{~fxGrp.set(\t_fxtrig, 1)}
		);
	},
	'/lefthand',
	nil,
	12345
);

OSCdef.new(
	\trackRHhit,
	{
		arg msg;
		if(
			msg[1] == \forward,
			{~fxGrp.set(\t_fxtrig, 1)}
		);
	},
	'/righthand',
	nil,
	12345
);
)

Evaluate all this, and finally, let's play these two Pbinds.

(
~engineStream = ~enginePat.play;
~glassStream = ~glassPat.play;
)

(
~engineStream.stop;
~glassStream.stop
)

Well, that's about it for tutorial 13. I hope you enjoyed it. In the next video, with OSC out of the way, I'd like to get back to the basics a little bit, and talk about topic which a lot of people have been requesting, and that is building and using Graphical User Interfaces, or GUIs for short. So as always, thanks for watching, and uh, see you next time.