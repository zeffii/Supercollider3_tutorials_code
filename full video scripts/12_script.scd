12_script

Hey everybody, welcome to tutorial 12. In this video, I'm gonna continue with OSC and show you the basics of getting wiimote data into SuperCollider, and using it to control sound. Out of necessity, this video is gonna be fairly specific to Mac OS. So if you're on another operating system, you might not find this video quite as helpful. But I'll try to put some useful information in the video description. Also, if you haven't watched the previous tutorial, I recommend you do so before watching this one, because it covers some fundamentals on the OSC protocol which in this video I'll sort of gloss over.

The Wiimote is a bluetooth device, so the basic process is to connect one or more wiimotes to your computer via bluetooth, translate that data into OSC messages, and then receive these messages in SuperCollider.

There is, actually, a WiiMote object in the class library. But from personal experience, and from what I've read on the SC listserv, I don't think this object works properly on Mac OS. Fortunately there's a bunch of software out there designed for the same purpose. In this video, I'm going to be using a program called OSCulator to translate wiimote data into OSC messages, which is available at OSCulator.net. At the time of making this video, the initial OSCulator download is free, but while it's running, OSCulator will periodically interrupt the flow of data to ask you to pay for the software. So this means the free version isn't really usable in a performance context, but it's fine for just messing around at home. The full version isn't very expensive, and more importantly it's very reliable and easy to use. In addition, the user manual for OSCulator is clear and thorough. I bought the full version awhile back and I've been very happy with it.

A quick word of advice about wiimotes-- make sure you have a wiimote which is actually manufactured by nintendo. Cheap knock-off versions of the wiimote do exist, and a student of mine purchased one, and then found out the hard way that it would not connect with osculator. So just to be safe, I do recommend that you buy the real thing.

Before opening OSCulator, you want to go to your bluetooth settings in system preferences and make sure Bluetooth is on and discoverable. My bluetooth is already on because I'm using a bluetooth keyboard and mouse. Then, open OSCulator, and a new default document should appear. In order to receive wiimote data, first we need to pair the wiimote with the computer. Click the wiimote button in the upper right to open the wiimote drawer. Now what you want to do is click the button that says 'start pairing', and while OSCulator scans for nearby wiimotes, you want to press and hold the small red button inside the wiimote battery compartment...like this. A green check mark should appear in the wiimote drawer, and the LED on the wiimote should light up. It's worth noting that if you're connecting a wiimote to your computer for the first time, you probably need to use the red button in the back to hard-sync the device to the computer. But if you've connected this wiimote to your computer before, I'm pretty sure you can just simultaneously press buttons 1 and 2 instead. But the red button should work in all cases.

One of many convenient features of OSCulator is that whenever OSC or wiimote data is received, that data is automatically added to the list on the main routing view, and automatically given an OSC address. Since I've waved the wiimote around a little bit after pairing, OSCulator has detected incoming data for pitch, roll, yaw, and accelerometer. (and it looks like i've accidentally pressed the B button as well). As soon as I press a button on the wiimote, a corresponding OSC address appears in the list, as you can see. OSCulator generates these addresses automatically, but you can change them if you want. A yellow light next to the address means that OSCulator is receiving data from that particular input.

Another nice feature is that you can click on a particular incoming message, let's click on pitch, then click the "quick look" button that appears on the top of the document, alternatively you can just hit spacebar. This brings up a live display of of the data for that message, and the data is normalized, so it ranges between zero and one....here's the roll data...and...yaw gives...shall we say, interesting results. I don't know this for sure, but I think the yaw data relies on the infrared sensor bar that sits above or below your screen when you're actually playing the wii. And I'm guessing that with respect to yaw data, without the infrared bar, the device just has no idea which way it's pointing. So I haven't really used yaw in any of my work, but I guess it makes a semi decent random number generator. Or maybe my wiimote is just broken. Who knows. Anyway here's the accelerometer data, which works just fine. Note that at rest position, values hover around 0.2. Quick motions tend to spike the data toward 1, and when the device is in freefall, the data dives close to zero. There's a small delay in the camera feed, but you get the picture. Buttons send a single value of 1 when depressed, and a single 0 when released.

So, let's take this data and send it to SuperCollider as a stream of OSC messages. I'm gonna start with pitch data. So next to pitch, in the event type column, select "OSC routing", and in the value column, select "new".

This brings up the parameters window, and there are two main views. On the top we have targets, where we identify the devices to which OSCulator sends OSC messages-- in this case, SuperCollider is our desired target. In the previous video, I mentioned that OSC messages are sent to a specific IP address, on a specific port. Since these messages are being sent to and from the same physical computer, I'm gonna use the loopback IP address 127.0.0.1. And remember that SuperCollider receives OSC messages on port 57120. You can double click and enter the IP address and port using the following syntax: 127.0.0.1:57120.

On the bottom view, we have a list of routes. This D on the left stands for default target, and the default target is determined by these radio buttons in the target list above. Right now of course we only have one target, and it is set as the default, so the D is fine, but alternatively you could select the number 1, since SuperCollider is listed as target number one. Click on the rewrite address column, and we can see that the default OSC message to be routed consists of the original address, automatically assigned by OSCulator, and all the arguments that make up this message-- of course in the case of pitch, it's just one numerical value corresponding to the pitch orientation. I'm going to leave the message as is for now, close the parameter window, and make sure the default target is selected for the pitch message. Notice that now we see a green light next to the pitch message, which indicates that data is not only being received by OSCulator, but also being routed elsewhere.

Now we're ready to receive this data in SuperCollider. Boot the server, and let's create a simple OSCdef to print the incoming data. As we saw in the previous tutorial, there are other arguments that can be included in the argument declaration, but right now I'm only interested in the message itself. Remember that the message is actually an array, where the 0th item is the address, and subsequent items are the message arguments. So I'm going to print the pitch data, which is at the 1st index. And we also need the incoming OSC address, specified as a symbol. We can see in the OSCulator document that the address for pitch is /wii/1/accel/pry, which stands for pitch roll yaw, and then we append /0, because we can see the zero just to the left of the word 'pitch'.

s.boot;

(
OSCdef.new(
	\pitch,
	{
		arg msg;
		msg[1].postln;
	},
	'/wii/1/accel/pry/0'
);
)

And there you have it, pitch data flowing into SC like tap water.

OSCdef(\pitch).disable;

It is possible to receive pitch, roll, yaw, and accelerometer data as four arguments in a single OSC message. If we go back to OSCulator, we can remove the routing for pitch, and add a routing for the parent message. Now, we just create a slightly different OSCdef, most importantly changing the incoming OSC address, but also displaying all four arguments.

(
OSCdef.new(
	\prya,
	{
		arg msg;
		msg[1..4].postln;
	},
	'/wii/1/accel/pry'
);
)

And we see an array of pitch, roll, yaw, and accelerometer data, in that order.

OSCdef(\prya).disable;

To process data from the buttons, the procedure is basically the same. Although I'm going to use this opportunity to show you how to customize the incoming OSC addresses. Let's say we want to get data from the A button. Choose OSC routing, and in the value column, click 'new'. Click the plus button to create a second routing (otherwise we'd overwrite the routing for the motion data). Then click the rewrite address for the new routing, and at the top of the editor, enter your preferred OSC address. I'm gonna keep things mega simple and just call this address /a. ) On the main routings page, make sure this new address is selected in the value column.

So now I should be able to make a new OSCdef to process this new incoming message, like so.

(
OSCdef.new(
	\abutton,
	{
		arg msg;
		msg[1].postln;
	},
	'/a'
);
)

So that's that essence of getting wiimote data into SuperCollider. The only thing left to do is actually make some sound. So we'll start with a SynthDef. The essence of this sound will be a very low frequency sawtooth wave, sent through a bandpass filter. A plain vanilla sawtooth wave at a subaudio frequency just sounds like a sequence of pops. But when sent through a high quality bandpass filter, we emphasize a narrow range of the frequency spectrum while attenuating the rest of the spectrum. In this way we can draw perceptable tones out of these otherwise noisy pops. The amplitude is shaped by an adsr envelope. The fundamental frequency deviates to some degree, and I'm multichannel expanding the UGen by 8, so we'll have 8 unique meandering sawtooth waves. Before going through the bandpass filter, I amplify these 8 waveforms by some amount, and then fold the waveforms back into a normalized range, iteratively, five times. Folding. Alright what's folding? If I had to put this technique in some sort of category, I'd say it's a form of distortion, kind of like clipping, but instead of flattening the portion of the signal that's out of range, that portion is folded back into range, so the +1 and -1 amplitude boundaries act sort of like a mirror. A sample with an amplitude of 1.1 would end up at 0.9, 1.2 would end up at 0.8, etc. And so a sawtooth wave, which ordinarily has these sharp corners, takes on even more of a jagged appearance after folding. Essentially this technique introduces some noise into an otherwise periodic signal. Moving on to the bandpass filter, both the center frequency and quality of the filter are randomized to some degree. And Splay distributes the array of 8 signals into 2 channels.

(
SynthDef(\foldsaw, {
	arg freq=4, detune=1, atk=0.01, dec=0.3, rel=3, c1=1, c2=(-1), gate=1,
	mincf=40, maxcf=12000, minrq=0.002, maxrq=0.2, boost=1.25, amp=1, out=0;
	var sig, env;
	env = EnvGen.kr(Env.adsr(atk,dec,0.5,rel), gate, doneAction:2);
	sig = Saw.ar(
		freq +
		LFNoise1.kr(LFNoise1.kr(0.5!8).range(0.1,1)).bipolar(detune);
	);
	5.do{sig = (sig*boost).fold(-1.0,1.0)};
	sig = BPF.ar(
		sig,
		LFNoise1.kr({ExpRand(0.005,0.05)}!8).exprange(mincf, maxcf),
		LFNoise1.kr({ExpRand(0.1,0.75)}!8).range(minrq, maxrq)
	);
	sig = Splay.ar(sig) * env * amp * 2;
	Out.ar(out, sig);
}).add;
)

using the default argument values I've provided, the SynthDef sounds like this:

x = Synth.new(\foldsaw);
x.set(\gate, 0);

So, big picture, here's what I'm going to do: The a button will add a Synth to an array, the b button will remove a synth from the array, assuming the array isn't empty. And the motion data will control sound parameters for the existing synths.

I'm going to create a group, and whenever I create a synth, i'll put it in this group. This will make it very easy to set parameters for all existing Synths, beacuse I can just address the group itself. I'll also create an empty array, in which Synths will be stored. I'm gonna make three OSCdefs- one for motion data, one for the a button, and one for the b button.

The OSCdef for the motion data will send a set message to the group, in effect this will set argument values for all synths in the group. the detune amount will be controlled by pitch orientation, exponentially mapped from 1 thousandth to 80Hz. But remember that the fundamental frequency of the sound is initially very low, so we won't hear a change in perceivable pitch, but rather we'll hear a change in the rate of filtered pops. And when the wiimote is pointed upward, the high detune value will cause the fundamental frequency to be above 20Hz, so we might hear the discrete oscillations of the sawtooth wave fuse into a perceivable tone. Roll will control the filter quality-- so when the wiimote is rolled to the left, we'll have a high quality filter, and a low quality filter when rolled to the right. high acceleration will increase the boost argument, which means the folding distortion will be more pronounced when the wiimote moves quickly.

Ok next OSCdef-- the a button. When the button is depressed, in other words, if the message from the A button equals 1, a new Synth is created and appended to the existing array, with a random frequency, attack time, and release time. For the b button, if the button is depressed and the array is not empty, fade out the oldest synth, and remove it from the array.

for extra clarity, I'm going to bring up the visual server tree, so we can actually watch as Synths are created and released.

And finally, I'm going to jump back to OSCulator to set up a routing for the B button, and double check to make sure everything is configured correctly.

s.plotTree;

(
g = Group.new;
a = [];

OSCdef.new(\prya, {
	arg msg;
	g.set(
		\detune, msg[1].linexp(0,1,0.001,80),
		\maxrq, msg[2].linexp(0,1,0.01,0.5),
		\boost, msg[4].linlin(0.2,1,1,16),
	);
	}, '/wii/1/accel/pry'
);

OSCdef.new(\a, {
	arg msg;
	if(
		msg[1]==1,
		{
			a = a.add(
				Synth.new(
					\foldsaw,
					[
						\freq, exprand(1,8),
						\atk, exprand(2,8),
						\rel, exprand(2,8),
					], g
				)
			)
		}
	);
	}, '/a'
);

OSCdef.new(\b, {
	arg msg;
	if(
		(msg[1]==1) && (a.size>0),
		{
			a[0].set(\gate, 0);
			a.removeAt(0);
		}
	);
	}, '/b'
);
)

And there you have it. Wiimotes and supercollider. It's worth noting that OSCulator is capable of connecting to eight wiimotes simultaneously, which gives you a lot more data to play with. And OSCulator doesn't just translate wiimote data to OSC-- it's a fully featured program when it comes to OSC routing, so you could have OSC messages coming from any number of sources, routed to any number of targets. You can also have multiple OSCulator documents open and running simultaneously, so the possibilities are endless. I hope you enjoyed this tutorial, and thanks for watching.