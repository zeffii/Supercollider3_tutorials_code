Hey everybody, welcome to tutorial 18. In this video we're gonna focus on generating MIDI messages in SC and sending them out to an external device. We started talking about MIDI back in tutorial 9, but in that video MIDI was only coming in to SC from an external controller, so here we're gonna flip things around.

We begin, as we did in tutorial 9, by initializing the MIDIClient class, with MIDIClient.init;

MIDIClient.init;

and we see right away that we have no available MIDI destinations, and obviously we need to fix that. For this video, I'm going be using a synthesizer plugin running inside a digital audio workstation on my computer, because I'm guessing this'll be, for most people, a relevant and practical thing to see, -- it's the kind of thing where if you have a DAW on your own computer, you can periodically pause this video and try out these ideas on your own. So I've got Logic open in the background, with an instrument track running FM8, which is a frequency modulation synth, and right now I've just got one oscillator modulating another. Now, of course, you don't have to use Logic, you don't have to use FM8, you can use whatever DAW and whatever plugin you like, it really doesn't matter, the general idea is gonna be the same, you just need to know how to configure your particular MIDI destination.

So, question 1 -- how do we get SC and Logic to talk to each other using MIDI? Well, conveniently, on macOS, there's a built-in feature called the IAC driver, which stands for inter-application communication, and this feature allows you to create one or more virtual MIDI busses, which serve as locations for sending and receiving MIDI data between one piece of software and another. To get to the IAC driver, we go to the Audio MIDI Setup Utility, and show the MIDI Studio window if it's not already visible, double-click on the little box that says IAC Driver, and make sure "device is online" is checked. And Logic even lets us know that we have a new MIDI input/output device available.

So, back in SC, we reinitialize the MIDIClient, and the IAC driver is visible here as well.

To output MIDI from SuperCollider, we first need to create an new instance of a class called MIDIOut, which I'm going to store using the global variable m. The first argument here is the port, and this is simply the index of the desired MIDI destination in the array returned by MIDIClient.destinations -- in this case we only have one destination in this array, so we specify index zero. And that's actually all we need, so we'll run this line.

m = MIDIOut.new(0);

And now we can send a MIDI message with this new instance, and we'll start with just a simple note-on message, which is done with m.noteOn, capital O. A note on message contains three pieces of information - first, the channel on which to send the message. Over in Logic, in the MIDI environment window, I'm using a channel splitter, which is patched so that FM8 is only listening to the first MIDI channel. And on the main window in the inspector column on the left, I've set the track's MIDI channel to be 1 as well. Remember that Logic thinks of this lowest numbered channel as channel 1, but SC, programming language that it is, treats it as channel 0.

Next is MIDI note number, which is an integer between 0 and 127, where 60 represents middle C on a piano, and last is note velocity, which on regular keyboard controllers, is determined by how fast you press a key, and on the receiving end most synthesizers will use this value to deterine amplitude or loudness. And this value should be between 1 and 127 because a zero velocity on some synthnesizers is interpreted as a note-off message, even if that message is technically a note-on message. So we'll do a value of 30 here. And then let's see if we can do a split screen kind of thing to actually see the message being sent and received

m.noteOn(0, 60, 30);

To stop the sound, we just need to send a corresponding note-off message, using the same channel and same note number.

m.noteOff(0, 60, 30);

The velocity of a note-off message, technically this represents the speed at which a key is released, but I think a lot of synthesizers just ignore this value, so for note-off velocity you can put whatever you like for velocity or just omit it entirely.

One handy feature of MIDIOut is that you can set the latency of an instance, which puts a delay on each message that gets sent

m.latency;

By default the latency is a fifth of a second, so we can increase that to a full second

m.latency = 1;
m.noteOn(0, 60, 30);
m.noteOff(0, 60, 30);

And with a value of zero, messages are sent immediately.

m.latency = 0;
m.noteOn(0, 60, 30);
m.noteOff(0, 60, 30);

This is actually want I for this demonstration, so I'm gonna keep that. Just keep in mind that this method doesn't provide total control of message latency, because some receiving devices sometimes have their own built-in latency. But this method is still really handy, especially when trying to synchronize two receiving devices that have different built-in latencies.

So yeah, anyway, some more examples, we can iterate over a collection of note numbers to create a chord:

(
[35,49,56,63,66,73].do{
	arg nn;
	m.noteOn(0, nn, 25);
}
)

(
[35,49,56,63,66,73].do{
	arg nn;
	m.noteOff(0, nn, 25);
}
)

And if we put this code in a Task or Routine, as we briefly saw in tutorial 17, we can include wait times, thus creating a sequence of MIDI messages.

(
Routine({
	[35,49,56,63,66,73].do{
		arg nn;
		m.noteOn(0, nn, 25);
		0.5.wait;
	}
}).play;
)

And then let's reverse the Array and turn these notes off:

(
Routine({
	[35,49,56,63,66,73].reverse.do{
		arg nn;
		m.noteOff(0, nn, 25);
		0.5.wait;
	}
}).play;
)

If we want to make specific changes to the quality of the sound, we need to do that over in Logic, because that's the program that's doing all the synthesis, for example, if we want each of these notes to have an amplitude envelope with a long attack and release.

(
Routine({
	[35,49,56,63,66,73].do{
		arg nn;
		m.noteOn(0, nn, 25);
		0.5.wait;
	}
}).play;
)

Comment out the wait time, all the notes get released together:

(
Routine({
	[35,49,56,63,66,73].reverse.do{
		arg nn;
		m.noteOff(0, nn, 25);
		//0.5.wait;
	}
}).play;
)

And of course, DAWs are full-featured tools for MIDI recording and editing, so we can record this sequence exactly as SuperCollider creates it.

So now I'm gonna undo this envelope, and let's edit this Routine so that it turns each note off before turning on the next one:

(
Routine({
	[35,49,56,63,66,73].do{
		arg nn;
		m.noteOn(0, nn, 25);
		0.1.wait;
		m.noteOff(0, nn);
		0.2.wait;
	}
}).play;
)

And if we enclose the contents of the Routine in curly braces and append dot loop, this sequence will play indefinitely.

(
r = Routine({
	{
		[35,49,56,63,66,73].do{
			arg nn;
			m.noteOn(0, nn, 25);
			0.1.wait;
			m.noteOff(0, nn);
			0.2.wait;
		}
	}.loop;
}).play;
)

r.stop;

But ok, so there's a potential problem here. Listen to what happens if I stop the routine at a particular moment

Logic gets a note on, but we sort of pull the plug before the corresponding note off is generated, so we get a stuck note. r.stop doesn't help, because the Routine's already stopped, and command period doesn't help either, because SC not doing the synthesis-- the server's not even booted.

So what I'm gonna do is go over to FM8 and hit this exclamation mark which is a so-called panic button that turns off all the signal .

So that's nice that FM8 has a panic button, but not every plugin is gonna have this, so let's try to figure out a more reliable solution for stuck notes. In the MIDI protocol, there exists a specific message called all notes off, which we can generate for a specific MIDI channel:

m.noteOn(0, 60, 30);
m.allNotesOff(0);

But guess what? That doesn't work. I find this message works sometimes but not always because we're relying on the receiving device to be programmed to understand this message and do the appropriate thing when received.

So, what I suggest for a more robust approach is to use iteration to manually generate a note off message for all 128 notes. Here's the shorthand for the array of integers 0 to 127, and using do, we pass the integers in as an argument and generate an individual note-off message for each note.


So here's a stuck note, I don't even know which one it is

m.noteOn(0, rrand(30,90), 30);

(0..127).do{arg n; m.noteOff(0, n)};

and that certainly does the trick. And, I think this line is handy enough that we should have SC do this automatically whenever we press command period. We can do this with the class CmdPeriod and the add method, and then providing this line of code, enclosed in curly braces as a function. This is very similar to what we did with ServerBoot, ServerTree, and ServerQuit classes in tutorial 17.

CmdPeriod.add({(0..127).do{arg n; m.noteOff(0, n)}}); //keep

So now, again, if I conjure up a bunch of stuck notes

m.noteOn(0,rrand(30,70),30);

and press command period -- all the notes turn off which is very cool because now the command period shortcut is behaving in the way we've sort of come to expect it to behave.

A brief detour to the internet here, I want to bring your attention to what I think is one of the best sites for understanding the technical aspects of MIDI, and that is midi.org. And once there, we go to specs, midi reference tables, and summary of MIDI messages. And if I do a find for "all notes off" - you can see that all notes off is not some SC-specific thing, it is a MIDI thing, it's actually part of the MIDI specification, and it seems like FM8 is just not programmed to respond to this particular message.

So anyway, that's sort of a basic introduction to sending note-on and note-off messages, so let's talk about continuous controller messages, also called control change messages or just CC messages. CC messages are what typically get generated when you turn a knob or move a fader on a physical MIDI controller, and these are basically like general purpose messages for controlling some aspect or parameter of sound in the receiving device.

On midi.org, we'll go back a page, and click on control change messages -- and here I want to point out that some controller numbers have pre-established functions -- things that they are expected to do, right out of the box, for example, controller 7 is associated with channel volume, or main volume. This means that if a synthesizer's design follows these specifications exactly, then a message received from controller number 7 should automatically affect main volume, without the user having to do any sort of custom mapping or configuration. So in SuperCollider let's generate a message from CC#7, and see whether the main volume of FM8 changes. After making a note, we create a CC message using m.control, and the syntax is similar to note messages, we provide the channel number, controller number, and controller value.

m.noteOn(0, 40, 60);
m.control(0, 7, 127);
m.noteOff(0, 40);

Turns out that works.

But what if we want to control some other parameter, like the level of the modulator oscillator feeding into the carrier, represented by the little white box here? Which sounds like this, by the way.

m.noteOn(0, 40, 60);
m.noteOff(0, 40);

Well, in the MIDI spec, there's understandably no pre-defined controller for frequency modulator level, that's a little too specific to be of practical use, but there are a number of controllers whose function is undefined -- meaning the user or developer can safely use these controller numbers for whatever they want, without the risk of overwriting or interfering with some function that already exists, like main volume. So while we could technically use controller 7 for modulator level, that's probably not a good idea because it might also adjust volume or disable volume control or something else undesirable. So let's go with controller 20, which according to midi.org is undefined, so probably a safe bet.

Now what we want to do is associate data from controller 20 with this modulator level going from oscillator E to F, and DAWs and plugins all do this slightly differently, so you might have to do a little research or read the manual to figure out how, but this feature is usually called MIDI learn. In FM8 we activate MIDI learn by first clicking this little 5-pin L button, right below the panic button, and then clicking the parameter we want to control, which puts a little red box around it.

And now FM8 is waiting for a CC message. So let's give it one. So I'll run this line, and watch the little box over in FM8. And something happened, so that's probably good -- you may find that some plugins and DAWs are designed so that they actually need two values from a controller before the assignment can be confirmed, so it might be necessary to send a second value on the same controller, like this

m.control(0, 20, 90);
m.control(0, 20, 91);

And yeah now the number representing modulator level has changed, so we're in good shape. For whatever reason everything in FM8 has a range of 0 to 100, even though it expects to receive a range between 0 and 127, so the values we send will show up as different numbers but that's not really a big deal, just something to be aware of.

So now with this controller assignment, we can do stuff like this:

m.noteOn(0, 40, 60);
m.control(0, 20, rrand(30,100));
m.noteOff(0, 40);

We'll do one more semi-complex example with a Routine before we move on. We'll start with a loop that turns on a note, and then iterates over the multiples of ten between 30 and 100, and on each pass, uses that number for the control value sent over to FM8, and waits for 0.3 seconds between each message:

(
r = Routine({
	loop{
		m.noteOn(0,30,60);
		(30,40..100).do{
			arg val;
			m.control(0, 20, val.postln);
			0.3.wait;
		};
	}
}).play
)

r.stop;

That command period function is definitely coming in handy

We can make a few modifications, we'll declare a local variable at the top of the loop, call it note, and it'll be a random integer between 28 and 40, we turn that note on, do our control iteration, and make sure to turn off the note the end of the loop, and I'll cut the wait time in half:

(
r = Routine({
	loop{
		var note;
		note = rrand(28,40);
		m.noteOn(0,note,60);
		(30,40..100).do{
			arg val;
			m.control(0, 20, val.postln);
			0.15.wait;
		};
		m.noteOff(0,note);
	}
}).play
)

r.stop

We can randomize these multiples of ten using the scramble method:

(
r = Routine({
	loop{
		var note;
		note = rrand(28,40);
		m.noteOn(0,note,60);
		(30,40..100).scramble.do{
			arg val;
			m.control(0, 20, val.postln);
			0.15.wait;
		};
		m.noteOff(0,note);
	}
}).play
)

r.stop

And if we want a predetermined sequence of notes, we can forget about rrand operator, and instead use a second, outer layer of iteration over a array of note numbers

(
r = Routine({
	loop{
		[30,40,30,45].do{
			arg note;
			m.noteOn(0,note,60);
			(30,40..100).scramble.do{
				arg val;
				m.control(0, 20, val);
				0.15.wait;
			};
			m.noteOff(0,note);
		}
	}
}).play
)

r.stop;

And just as a reminder we can record this entire sequence.

(
r = Routine({
	loop{
		[30,40,30,45].do{
			arg note;
			m.noteOn(0,note,60);
			(30,40..100).scramble.do{
				arg val;
				m.control(0, 20, val);
				0.15.wait;
			};
			m.noteOff(0,note);
		}
	}
}).play
)

r.stop;

Here's our note data, and...if we go to View, MIDI Draw, and Other -- here's our control data on controller number 20. It's all there.

So, this Routine-based approach is fine for relatively simple ideas, but for more complex and algorithmic ideas, the syntax here would probably gonna get kind of sloppy, and also, this approach isn't really very accommodating for on-the-fly real-time manipulations. And so we have the option of using SuperCollider's very powerful pattern library, most notably the Pbind object, to generate MIDI in a more elegant way.

Pbind, as discussed in tutorial 10, generates events, and the default event type, which I'm going to specify here explicitly, is the so-called note event, which instantiates Synths on the server. So, ten second refresher, here's a very simple SynthDef which plays a tone with an exponential decay, and we create a stream of note events using this SynthDef by playing the following Pbind

s.boot;

(
SynthDef(\basic, {
	arg freq=440;
	var sig;
	sig = SinOsc.ar(freq)!2;
	sig = sig * XLine.kr(0.2,0.01,0.3,doneAction:2);
	Out.ar(0, sig);
}).add;
)

(
p = Pbind(
	\type, \note,
	\instrument, \basic,
	\dur, 0.15,
	\midinote, Pseq([50,55,57,60,67],inf),
).play
)

p.stop;

But, what you may not know is that there are tons of different event types that Pbind can generate, as we can see in chapter 8 of h. james harkins' practical guide to patterns. right so, event types, and here's the default "note" type event, and we'll just make our way down the file here...my god there's so many -- ok here, MIDI output: there is an event type called "midi", so we'll wipe out this Pbind and specify midi as the type of event:

(
Pbind(
	\type, \midi,

).play
)

In the case of MIDI events, we need to tell Pbind what type of MIDI message to create, which is done with the midicmd key, specified as a symbol. The available MIDI commands include things like noteOn, noteOff, our friend allNotesOff, which may or may not work properly, control, bend, etc. So let's send noteOn messages.

(
Pbind(
	\type, \midi,
	\midicmd, \noteOn,

).play
)

midi events also need to know where they're supposed to go, in other words, which instance of MIDIOut they are supposed to use. So, the key we need here is \midiout, and the value is our global variable m

(
Pbind(
	\type, \midi,
	\midicmd, \noteOn,
	\midiout, m,

).play
)

Subsequent keys depend on the type of message being generated. Since we're making note-on messages, we need to specify the channel using the "chan" key, and midi note number, and here's where we can get a little creative. Let's use Pwrand to do a weighted random choice between four Ds in different octaves, giving the most weight to MIDI note 74, and we'll have Pwrand make these choices indefinitely. And instead of a velocity symbol, midi events expect the symbol amp, which is consistent with note-type events, and here a value of 1 corresponds to the maximum velocity of 127, a value of 0.5 corresponds to a velocity of 63, etc. and if you find this confusing or annoying, and you'd rather specify raw velocity values, then you can just do that and divide that raw value by 127, like this. I'm actually gonna use Pexprand and choose velocity values between 5 and 100. Then, we have the sustain key, which is how many seconds to wait after a note-on before sending out the corresponding note-off message, and this is really handy because previously, using routines, we had to provide note off messages explicitly, but here we just provide a sustain time, and the note-off is generated automatically. So I'm gonna do a fixed value of 0.02 seconds, for fairly short notes. And then, of course, regardless of the event type, we need the dur key to determine the delta time between successive events, let's do 0.15 seconds. And just to be clear, sustain is the length between a note-on and note-off. Dur is the length of time between successive note-on messages. I'm also going to name this event stream ~fm8

(
~fm8 = Pbind(
	\type, \midi,
	\midicmd, \noteOn,
	\midiout, m,
	\chan, 0,
	\midinote, Pwrand([62,74,86,98],[0.1,0.8,0.08,0.02],inf),
	\amp, Pexprand(5,100,inf)/127,
	\sustain, 0.02,
	\dur, 0.15
).play
)

I'm gonna increase the envelope release just a little...and put a reverb effect on this track.

~fm8.stop;

Cool, cool, so, if we're sending rhythmic stuff to a DAW, we probably want to set an appropriate project tempo in the DAW, and have our SC patterns be rhythmically consistent with that tempo because that's just a sensible thing to do, it's gonna make DAW-based time adjustments much much easier. I'm gonna show the tempo track, and I'll set this to 108 bpm. And then back in SC, like we did in tutorial 10, I'll provide a raw metric value for the dur key, in this case, 16th notes, and use the stretch key to set the length of one bar of 4/4 - so 60/108 gives us seconds per beat, and 4 times this value gives us seconds per bar.

So if we now record this sequence

(
~fm8 = Pbind(
	\type, \midi,
	\midicmd, \noteOn,
	\midiout, m,
	\chan, 0,
	\midinote, Pwrand([62,74,86,98],[0.1,0.8,0.08,0.02],inf),
	\amp, Pexprand(5,100,inf)/127,
	\sustain, 0.02,
	\dur, 1/16,
	\stretch, 4*60/108
).play
)

~fm8.stop;

And then jump back to Logic, and nudge everything so that it starts on a downbeat, we can see, or hopefully you can see, that everything aligns very nicely with the tempo grid -- of course if you want to be extra sure they are rhythmically precise, you can always quantize these notes.

Ok so now let's make a pattern to send CC messages that control the modulator level within FM8. This'll be similar to the previous Pbind in a lot of ways, first lets give this Pbind a different name, fm8 underscore cc20. midicmd this time is going to be control, same MIDIOut instance, and same channel, control messages need to know the controller number, specified with ctlNum, and the controller value, specified with the \control key, and this is all pattern guide chapter 8... for controller values we'll pick randomly between 1 and 80, rounding to the nearest integer, Pexprand favors low values -- so most often we'll get a nearly pure sine wave, but occasionally a brighter, frequency-modulated timbre. and I'm gonna keep the rhythm of the control pattern synchronized with the note pattern, so just copy and paste the dur and stretch items.

(
~fm8 = Pbind(
	\type, \midi,
	\midicmd, \noteOn,
	\midiout, m,
	\chan, 0,
	\midinote, Pwrand([62,74,86,98],[0.1,0.8,0.08,0.02],inf),
	\amp, Pexprand(5,100,inf)/127,
	\sustain, 0.02,
	\dur, 1/16,
	\stretch, 4*60/108
).play
)

(
~fm8_cc20 = Pbind(
	\type, \midi,
	\midicmd, \control,
	\midiout, m,
	\chan, 0,
	\ctlNum, 20,
	\control, Pexprand(1,80,inf).round,
	\dur, 1/16,
	\stretch, 4*60/108,
).play
)

When we stop the control pattern, rather than just letting the last randomly determined value persist indefinitely, we might want to provide a specific control message just to sort of manually reset this parameter;

~fm8_cc20.stop;
m.control(0, 20, 1);

~fm8.stop;

So the last thing I want to do is quickly pull up a second instrument track, I'm gonna use a plugin called Retro Synth, [record enable] and before recording this video I saved a preset patch, and in the MIDI Environment window I want to make sure that Retro Synth is listening for MIDI on channel 2, and I'm gonna also check the inspector column to make sure the track setting is consistent, and this means we're going to be able to have two completely separate note streams, with these two synthesizers listening exclusively on two different channels. And let's just making sure FM8 is still listening on the first channel

m.noteOn(0, 70, 80);
m.noteOff(0, 70);

And Retro Synth, listening on the next channel, sounds like this:

m.noteOn(1, 70, 80);
m.noteOff(1, 70);

And because we're now working with a second MIDI channel, it would be wise to add a second function to CmdPeriod that sends 128 note-off messages on this additional channel as well

CmdPeriod.add({(0..127).do{arg n; m.noteOff(1, n)}});

And finally, we'll make one last Pbind to play some background chords using retro synth.

So, we want noteOn events, MIDIout, m, channel 1, instead of 0, for midinote I'm going to use Pxrand to choose between three chords from the key of d minor, Pxrand is nice for this because it never picks the same thing twice in a row, Pwhite to randomly choose velocities between 15 and 30, sustain these notes for somewhere between 4 and 8 seconds, and generate a chord every 4 6 or 8 bars.

If we want these two patterns to play at exactly the same, what I like to do is use the quant argument, which we saw in tutorial 10, so that both patterns will start exactly on the next available downbeat.

(
~fm8 = Pbind(
	\type, \midi,
	\midicmd, \noteOn,
	\midiout, m,
	\chan, 0,
	\midinote, Pwrand([62,74,86,98],[0.1,0.8,0.08,0.02],inf),
	\amp, Pexprand(5,100,inf)/127,
	\sustain, 0.02,
	\dur, 1/16,
	\stretch, 4*60/108
).play(quant:4*60/108);

~retroSynth = Pbind(
	\type, \midi,
	\midicmd, \noteOn,
	\midiout, m,
	\chan, 1,
	\midinote, Pxrand([
		[38,50,72,77,81],
		[43,55,70,77,79],
		[46,58,69,74,77,84]
	],inf),
	\amp, Pwhite(15,30,inf)/127,
	\sustain, Pexprand(4.0, 8.0),
	\dur, Prand([4,6,8],inf),
	\stretch, 4*60/108,
).play(quant:4*60/108);
)

Let's add our control pattern to the mix:

(
~fm8_cc20 = Pbind(
	\type, \midi,
	\midicmd, \control,
	\midiout, m,
	\chan, 0,
	\ctlNum, 20,
	\control, Pexprand(1,60,inf).round,
	\dur, 1/16,
	\stretch, 4*60/108,
).play(quant:4*60/108);
)

~fm8_cc20.stop;
m.control(0,20,1);
~retroSynth.stop;
~fm8.stop;

And if we really want to make this super fancy and allow real-time control, while the pattern is playing, then I recommend augmenting with the Pdef object, demonstrated toward the end of tutorial 10, because, it allows us to make changes to the patterns, without disrupting them, simply by editing and re-evaluating the code.


(
Pdef(\fm8, Pbind(
	\type, \midi,
	\midicmd, \noteOn,
	\midiout, m,
	\chan, 0,
	\midinote, Pwrand([62,74,86,98],[0.1,0.8,0.08,0.02],inf),
	\amp, Pexprand(10,90,inf)/127,
	\sustain, 0.02,
	\dur, 1/16,
	\stretch, 4*60/108
)).play.quant_(4*60/108);
)

(
Pdef(\retroSynth, Pbind(
	\type, \midi,
	\midicmd, \noteOn,
	\midiout, m,
	\chan, 1,
	\midinote, Pxrand([
		[38,50,72,77,81],
		[43,55,70,77,79],
		[46,58,69,74,77,84]
	],inf),
	\amp, Pwhite(15,30,inf)/127,
	\sustain, Pexprand(4.0, 8.0),
	\dur, Prand([4,6,8],inf),
	\stretch, 4*60/108,
)).play.quant_(4*60/108);
)

(
Pdef(\fm8_cc20, Pbind(
	\type, \midi,
	\midicmd, \control,
	\midiout, m,
	\chan, 0,
	\ctlNum, 20,
	\control, Pexprand(1,60,inf).round,
	\dur, Pseq([1/16],inf),
	\stretch, 4*60/108,
)).play.quant_(4*60/108);
)

[record in Logic]
fm8 amp down to 10, gradually bring up
(plus 7 on midinote, sustain up to 0.08)

Pdef(\fm8_cc20).stop;
m.control(0,20,1);

Pdef(\retroSynth).stop;
Pdef(\fm8).stop;

And that's it for tutorial 18. So, there's no denying that the DAW is a great tool for audio, [switch over to logic] just basically indispensable, it's graphically intuitive, and gives you access to interesting sound very quickly. But what it doesn't have is the high-level vocabulary for algorithmic expression that SuperCollider's pattern library provides, [switch over to SC] so I hope you can see that by combining these two platforms, a lot of new possibilities become available. Normally, in a DAW, you get MIDI into the software by pushing keys and buttons on a controller, which is inherently limited by human physicality, but with SuperCollider, you code your own pattern, hit record, walk away and get a cup of coffee, come back and you've got half an hour's worth of algorithmically generated MIDI. So yeah I hope you got something useful out of this video, as always if you have any questions or comments, please leave them below, thank you so much for watching, and see you next time.