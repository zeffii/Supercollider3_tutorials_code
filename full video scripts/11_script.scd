//on iPad, quit all apps, make sure on wifi

//video description
opensoundcontrol.org

Hey, welcome to tutorial 11. In the next few videos, we're gonna take a look at how SuperCollider integrates with the Open Sound Control protocol, more commonly known as OSC. In contrast to the MIDI protocol, OSC is faster, more flexible, more time-accurate, and doesn't include a hardware specification. OSC messages are most commonly sent over the internet, taking advantage of established net transmission protocols such as UDP and TCP. The syntax of an OSC message consists of a URL-style address, followed by some number of arguments. Often these arguments are numbers, but not always. OSC messages are sent over a network to a specific IP address on a specific port.
//////////////////////

In this video, I'll be using TouchOSC, which is a multi-touch interface designer for iOS and Android. You can find some links and resources in the video description.

//OSC DISABLED on TouchOSC

So let's open TouchOSC. Right now we're looking at the main settings page, where you can set up your OSC connection, choose an interface layout, etc. In the layout list, you can view the available layouts, tap the one you want, I'll choose Jog-On, and then hit 'Done' in the upper right corner to bring it up. All the controls on this layout send OSC messages, but they won't do anything right now because I haven't set up an OSC connection yet. You can return to the main settings page by tapping the button in the upper right corner. In many cases, you'll probably want to make your own custom interface. You can't actually create or edit layouts within the TouchOSC app, instead, this is done in a separate application called TouchOSC editor.

Since I'm using an iPad, I'm going to select the iPad layout size, and choose a horizontal orientation. Right-click or control-click on the canvas to bring up a list of available controls, and I'm going to keep things simple and just drop a few things onto the canvas.  I'll grab a toggle button, two H faders, and an H rotary. You can move and resize controls by clicking and dragging, holding shift while dragging preserves the height-width ratio, and you can also copy and paste just as you would with a text editor. If you click on one of these controls, a panel appears on the left side of the editor, where you can change the color, the numerical output range, and various other parameters specific to that control. For example, I can change the rotary to be centered. If I click on the canvas, we can see that the name of this particular page is simply the number 1. Clicking on the toggle button, for example, you can see that the address of this control is /1/toggle1. This is the URL-style address I mentioned earlier. You can uncheck 'auto' and give your controls custom OSC addresses if you want, but they must start with a slash and look like a URL address. If I click on the page and change its name, then the controls' addresses are automatically updated to reflect the new page name. Here the new address is /main/toggle1. To add a new page, right click on the canvas top bar. The name of the new page defaults to the number 2, so if we add a control here, it's URL address is /2/fader3. (delete)

Let's stop here and save this interface, I'll name it 'basic'. Make sure to save it in the TouchOSC layouts folder. After saving, we need to synchronize this layouts folder with the TouchOSC app. At the top, click 'sync,' and a window with step-by-step instructions appears. The first thing we need to do is make sure the computer and mobile device are both on the same network. I can see in the menu bar that my computer is on my home network. And I can verify that the iPad is connected to this same network. So that's the first step out of the way. The next thing we need to do is go into the TouchOSC app and navigate to Layout >> Add. On this screen, sometimes available TouchOSC hosts will pop up automatically, and sometimes they wont. (In this case, I can just tap my computer's name. In this case, it looks like the host computer isn't showing up). If you don't see your host computer, touch 'edit' in the upper right corner, then the plus sign in the upper left corner, and you can enter the computer's local IP address manually. On Mac OS, in System Preferences, under Network, I can check my local IP address, which happens to be [???.???.???.???]. So, back in TouchOSC, I simply enter this IP address exactly as it appears, hit enter, and tap the IP address that appears. And now, we can see that our 'basic' layout has been added to the layout list. Select it, and touch 'done'.

Ok, so with that out of the way, let's read this OSC data into SuperCollider, and just print it in the post window. For this, we use one of two objects: OSCFunc, or OSCdef. Since I used MIDIdef in tutorial 9, I'll use OSCdef for the sake of consistency. But first, we need to boot the server, since IT is the program which actually sends and receives OSC data.

s.boot;

Before we move forward, I want to draw your attention to the help documentation, in particular, under Browse >> External Control >> OSC, and here we have a handful of relevant files. In particular, I suggest reading the guide called OSC Communication.

I'm going to make an OSCdef that'll respond to OSC messages coming from the toggle button on the TouchOSC interface. The first argument is a symbolic name, and next we need a function to be evaluated when an OSC message is received. As was the case with MIDIdef functions, an OSCdef function also allows for a specific collection of input arguments. The OSCdef help file reads that 'When the function is evaluated it will be passed the arguments msg, time, addr, and recvPort'. So let's create four arguments for this function, enclose them in an Array, and just post them.

(
OSCdef.new(
	\toggle,
	{
		arg msg, time, addr, port;
		[msg, time, addr, port].postln;
	}
)
)

An OSCdef also needs the URL-style address corresponding to the source of the OSC message. We can see from the TouchOSC Editor that the toggle's path is /main/toggle1. We provide this address to the OSCdef as a Symbol. But, if we create a symbol using the backslash approach like usual, SuperCollider has trouble with this, syntactically. Instead we forgo the backslash syntax and use the alternate Symbol syntax of enclosing the address in single quotes.

(
OSCdef.new(
	\toggle,
	{
		arg msg, time, addr, port;
		[msg, time, addr, port].postln;
	},
	'/main/toggle1'
)
)



This is generally enough data to get OSCdef to behave the way you want. But there's one last step. We have to jump back to TouchOSC and establish the OSC connection from that side. First things first, on the main settings page, we need make sure OSC communication is enabled. Next we need specify the IP address of the host computer, which we know to be [???.???.???.???]. The outgoing port should match the port that SuperCollider is listening to. By default, SuperCollider listens for incoming OSC data on port 57120, we can verify this by evaluating

NetAddr.langPort;

Next we need the incoming OSC port, and since we're not planning on sending data to TouchOSC, this doesn't really apply. And last is the local IP of the mobile device. In some cases you might have data coming from multiple OSC sources, in which case it might be necessary to take note of these different IP addresses, so you can separate out different streams of data. But in this case, it's not really necessary to know.

Let's go to our saved basic layout, jump back to SuperCollider, and finally, let's evaluate the OSCdef.

(
OSCdef.new(
	\toggle,
	{
		arg msg, time, addr, port;
		[msg, time, addr, port].postln;
	},
	'/main/toggle1',
);
)

If I now tap the toggle button on TouchOSC, we'll see the corresponding OSC data appear in the post window. So, the hard part's over. We're looking at all the data from the toggle button, including the address, the time received, the IP address of the source device... and maybe we don't want to see all that data. If we only want to see the OSC message proper, we can just remove the other arguments from the function and re-evaluate.

(
OSCdef.new(
	\toggle,
	{
		arg msg, time, addr, port;
		msg.postln;
	},
	'/main/toggle1',
);
)

Notice that the message argument is, itself, an array, which contains the OSC address, followed by some number of numerical values (in this case, just the one toggle value). So if we only want the numerical arguments, but not the message address, we can ask for the item at index 1 within the message array, like this.

(
OSCdef.new(
	\toggle,
	{
		arg msg, time, addr, port;
		msg[1].postln;
	},
	'/main/toggle1',
);
)

So that's looking pretty good. I'll make three more OSCdefs for the remaining three controls. One for the first fader...one for the second fader...and one for the knob.

(
OSCdef.new(
	\toggle1,
	{
		arg msg, time, addr, port;
		("toggle: "++msg[1]).postln;
	},
	'/main/toggle1',
);

OSCdef.new(
	\fader1,
	{
		arg msg, time, addr, port;
		("fader 1: "++msg[1]).postln;
	},
	'/main/fader1',
);
OSCdef.new(
	\fader2,
	{
		arg msg, time, addr, port;
		("fader 2: "++msg[1]).postln;
	},
	'/main/fader2',
);
OSCdef.new(
	\rotary1,
	{
		arg msg, time, addr, port;
		("rotary 1: "++msg[1]).postln;
	},
	'/main/rotary1',
);
)

Back on the TouchOSC interface, here's the toggle again, fader 1... fader 2... and the knob. So everything's working, and now we're in a good position to start using this data to make sound.

So I'm gonna quickly contstruct a SynthDef. An adsr envelope will control the amplitude of the sound, and the gate will be closed by default. The source of the sound will come from Blip.ar, which generates harmonic partials. I'll set a fundamental frequency, and to create a detuning feature, I'll multiply the frequency by a slow moving LFNoise1, ranging between negative and positive detune values. I'm envisioning detune as a number of semitones, so I'll use midiratio to make the output values suitable for frequency scaling. I also want to add a second argument to Blip for the number of harmonic partials to generate. I'm going to multichannel expand the noise generator, which means the enclosing Blip UGen is expanded to an array of 16 Blip generators each with a uniquely meandering frequency.

For additional complexity, I'll also vary the amplitude with another sixteen unique noise generators.

But since we don't have sixteen speakers, I'll use Splay to mix the 16 audio channels down to stereo. Next I want to be able to balance the left and right channels independently. But I can't use Pan2, because Pan2 expects a monophonic signal. Instead, I'll use Balance2. Balance2 expects the left channel, which I can specify as sig at 0, the right channel, sig at 1, and the pan control. Apply the envelope, apply the master amplitude argument, and output the signal.

(
SynthDef.new(\tone, {
	arg freq=40, nharm=12, detune=0.2, gate=0, pan=0, amp=1, out=0;
	var sig, env;
	env = EnvGen.kr(Env.adsr(0.05,0.1,0.5,3), gate);
	sig = Blip.ar(
		freq * LFNoise1.kr(0.2!16).bipolar(detune).midiratio,
		nharm
	);
	sig = sig * LFNoise1.kr(0.5!16).exprange(0.1,1);
	sig = Splay.ar(sig);
	sig = Balance2.ar(sig[0], sig[1], pan);
	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;
)

Let's test it to make sure everything's working

x = Synth.new(\tone, [\gate, 1])

x.set(\freq, 50)
x.set(\pan, 0.0)
x.set(\nharm, 12)
x.set(\detune, 0.25)
x.set(\amp, 1)
x.set(\gate, 0)

Ok cool. So using TouchOSC, I'd like to be able to control these parameters. gate, fundamental frequency, detune, number of harmonics, panning, and overall amplitude. So that's six parameters, but I've only got four controls on the interface. Fortunately, modifying layouts is really quick and easy. Switch over to the editor, make the desired changes, save the layout, click Sync, and on TouchOSC, go to the layout list, tap Add, select the host device, and it'll ask you if you want to overwrite your previous layout, tap ok, go back to the main settings page, and tap 'done'.

Now all we need to do is add two more OSCdefs, and modify the functions of all 6 OSCdefs to control our Synth. I'll have the toggle control the gate, the first fader will control the frequency, but right now the fader ranges between 0 and 1, and these aren't suitable frequency values. So I have map this normalized output to a new range, suitable for audible frequency values. You can do this in TouchOSC or SuperCollider, whichever your prefer. I'll have the 2nd fader control the number of harmonics, the last fader, the overall amplitude. Technically I don't need to map these values, but I prefer an exponential range of amplitude values. The centered rotary will control panning, and the last rotary will control detuning, with a maximum of 12 semitones.

(
OSCdef.new(
	\toggle1,
	{
		arg msg;
		x.set(\gate, msg[1]);
	},
	'/main/toggle1',
);
OSCdef.new(
	\fader1,
	{
		arg msg;
		x.set(\freq, msg[1].linexp(0,1,20,400));
	},
	'/main/fader1',
);
OSCdef.new(
	\fader2,
	{
		arg msg;
		x.set(\nharm, msg[1].linlin(0,1,1,50));
	},
	'/main/fader2',
);
OSCdef.new(
	\fader3,
	{
		arg msg;
		x.set(\amp, msg[1].linexp(0,1,0.005,1));
	},
	'/main/fader3',
);
OSCdef.new(
	\rotary1,
	{
		arg msg;
		x.set(\pan, msg[1].linlin(0,1,-1,1));
	},
	'/main/rotary1',
);
OSCdef.new(
	\rotary2,
	{
		arg msg;
		x.set(\detune, msg[1].linexp(0,1,0.01,12));
	},
	'/main/rotary4',
);
)

And that's about it for tutorial number 11. In the next few videos I'd like to demonstrate how to use SuperCollider with the Nintendo Wiimote, as well as the Xbox Kinect, so stick around for more OSC tutorials. I also want to say a very genuine thank you to all the viewers and subscribers. I've gotten a lot of positive feedback on these videos, and I'm very happy to know that people find them useful and enjoyable. So, thanks for watching! See you next time.