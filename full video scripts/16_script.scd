s.boot;
s.meter;
s.plotTree;
s.record;

Hey everybody, welcome to tutorial 16. This'll be a continuation of the previous video, so we're gonna pick up where we left off and develop some more SynthDefs and touch on a few other ideas that we can use in the context of a short composition. In the last video we coded this multi-purpose bandpass filtered sawtooth instrument, but one thing it doesn't do is process sound files. So, for the sake of variety, let's build a SynthDef that's capable of sound file playback.

On the Desktop, I've prepared a folder called buffers, which contains three subfolders of crotales, desk bell, and shaker sounds. We will deal with this entire collection of audio files a little bit later, but for now, we're just going to focus on these three sustained shaker sounds. So, boot the server and just read these files into Buffers, simply using three Buffer.read statements, which we saw in tutorial 8. Remember you can drag and drop a file into the editor, and it'll be converted to a string representing its path.

s.boot;

//make sure these paths are correct
~b1 = Buffer.read(s, "/Users/eli/Desktop/Tutorial Piece/buffers/shakers/shakerSustain01.aiff");
~b2 = Buffer.read(s, "/Users/eli/Desktop/Tutorial Piece/buffers/shakers/shakerSustain02.aiff");
~b3 = Buffer.read(s, "/Users/eli/Desktop/Tutorial Piece/buffers/shakers/shakerSustain03.aiff");

~b3.play;

So what I want to do here is construct a SynthDef that plays a buffer, applies an amplitude envelope and stereo panning, and optionally routes the sound through a bandpass filter. And for me, a bandpass filter seems like sort of a desirable choice here because with a high quality filter, the narrow filter band makes it possible to bring out one particular frequency, which will allow us to apply harmonic or melodic ideas to our otherwise unpitched shaker sounds.

So we'll start with a fixed length envelope generator, with attack, sustain, and release segments, also giving ourselves the option to control the curves of the attack and release segments. And we'll use PlayBuf as our buffer playing ugen. I happen to know that all of my sound files are monophonic, as we can verify with numChannels,

~b1.numChannels;

so the first argument of PlayBuf should be a 1, then the bufnum, and then the rate argument, and remember that PlayBuf treats this argument as a ratio, so 2 is twice as fast, 0.5 is twice as slow. Multiplying the rate argument by BufRateScale, as we saw in tutorial 8, is not absolutely necessary, but it's a safe thing to do, because if your audio files have been recorded at a sample rate that's different from the SuperCollider server sample rate, BufRateScale will compensate for the difference, and that means a rate value of 1 will always play back the file at normal speed. And since I'm not planning to change the bufnum while the Synth is running, it's perfectly reasonable to use the ir method which is a little bit more efficient, although it should be noted that the difference in efficiency is probably very small, and kr would work just fine. And I'm also going to specify a value for the playbuf start position, in case we want to start from somewhere in the middle of an audio file.

Notice that the envelope has doneAction2, not the playbuf. This is because I'm envisioning the envelope generator as a governing amplitude process, and we'll multiply sig and env together later on, and when the envelope finishes, we get silence, regardless of whether playbuf has been able to get through the entire sound file. So at the end of the envelope, there's no reason to keep the Synth hanging around any longer, so doneAction 2 gets rid of it.

(
SynthDef(\bpfbuf, {
	var sig, env;
	env = EnvGen.kr(Env([0,1,1,0],[atk,sus,rel],[c1,0,c2]),doneAction:2);
	sig = PlayBuf.ar(1,buf,rate*BufRateScale.ir(buf),startPos:spos);
}).add;
)

To add the bandpass filter, we'll use XFade2, which is an equal power crossfade ugen, this will enable us to smoothly balance between the unfiltered signal and the bandpass signal. This fourth BPF argument is the amplitude of the filter output, and just like we saw in tutorial 14, I'm creating an inverse relationship between reciprocal quality amplitude. This provides a boost in amplitude to compensate for the loss in amplitude resulting from a narrow filter band. The third argument of XFade2 is the crossfade mix between the two signals, where -1 favors the first signal, positive 1 favors the second, and 0 is a 50-50 crossfade. Usually I prefer to specify the mix using a range between 0 and 1, so I'll multiply this mix argument by two and subtract 1. Mathematically, this converts my preferred range of 0 to 1, to XFade2's expected range of -1 to +1.

Apply the amplitude envelope, and apply the stereo panning, this is where I also like to add a master amplitude argument, and output the signal. And finally, of course, we need to declare all of these arguments that we created.

(
SynthDef(\bpfbuf, {
	arg	atk=0, sus=0, rel=3, c1=1, c2=(-1),
	buf=0, rate=1, spos=0, freq=440, rq=1, bpfmix=0,
	pan=0, amp=1, out=0;
	var env, sig;
	env = EnvGen.kr(Env([0,1,1,0],[atk,sus,rel],[c1,0,c2]),doneAction:2);
	sig = PlayBuf.ar(1,buf,rate*BufRateScale.kr(buf),startPos:spos);
	sig = XFade2.ar(sig, BPF.ar(sig, freq, rq, 1/rq.sqrt), bpfmix*2-1);
	sig = sig * env;
	sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig);
}).add;
)

So, only specifying which buffer to play, our SynthDef sounds like this.

Synth(\bpfbuf, [\buf, ~b2.bufnum]);

Note that you actually need to include .bufnum, because SuperCollider still knows what we mean without it.

Synth(\bpfbuf, [\buf, ~b2]);

By default, the attack and sustain times are zero, so we immediately begin a three second release. But we can specify a different envelope shape. For example here's very short segment pulled randomly from somewhere in the first half of the buffer.

(
Synth(
	\bpfbuf,
	[
		\buf, ~b2,
		\rel, 0.1,
		\spos, rrand(0, ~b2.numFrames/2),
	]
);
)

Or we can increase the attack and sustain portions for a more gradual amplitude shape.

(
Synth(
	\bpfbuf,
	[
		\buf, ~b2,
		\atk, 2,
		\sus, 1,
		\rel, 2,
	]
);
)

Bpfmix is zero by default, but if we specify a value of one, we take the unfiltered signal out of the mix completely and instead only hear the output of the bandpass filter. And let's say a center frequency of 2000 Hz...and now let's gradually increase the filter quality...With higher quality values, we start to hear that ringing resonance that bandpass filters are capable of.

(
Synth(
	\bpfbuf,
	[
		\buf, ~b2,
		\atk, 2,
		\sus, 1,
		\rel, 2,
		\bpfmix, 1,
		\freq, 2000,
		\rq, 1/400,
	]
);
)

Varying the playback rate will play the file back faster or slower, but it won't have much of an effect on the pitch we perceive, because the pitch is being governed by the frequency argument.

(
Synth(
	\bpfbuf,
	[
		\buf, ~b2,
		\atk, 2,
		\sus, 1,
		\rel, 2,
		\bpfmix, 1,
		\freq, 2000,
		\rq, 1/400,
		\rate, 0.5
	]
);
)

Let's randomize which buffer to play, also the attack and release, and for the filter frequency, I'm gonna specify an A lydian pitch collection, making sure to convert to cycles per second, with a possible transposition up one octave, and also random values for quality, playback rate, and panning. Now, even though in our SynthDef we are compensating for the loss of amplitude resulting from the filter, if you were looking at the level meters you might have noticed that this is still a relatively low level signal, so I'm going to boost the amplitude values a little bit above 1. Generally this is an ok thing to do, as long as you're paying attention to the level meters and gradually increase amplitude values, rather than suddenly jumping up to some huge value, which is not a good idea.

(
Synth(
	\bpfbuf,
	[
		\buf, [~b1,~b2,~b3].choose,
		\atk, exprand(2,3),
		\sus, 0,
		\rel, exprand(2,3),
		\bpfmix, 1,
		\freq, (Scale.lydian.degrees+69).choose.midicps * [1,2].choose,
		\rq, exprand(0.001,0.008),
		\rate, exprand(0.6,1.2),
		\pan, rrand(-0.5,0.5),
		\amp, exprand(4,6),
	]
);
)

And maybe as a final touch, we can use iteration to generate many of these Synths all at once.

(
rrand(4,10).do{
	Synth(
		\bpfbuf,
		[
			\buf, [~b1,~b2,~b3].choose,
			\atk, exprand(2,3),
			\sus, 0,
			\rel, exprand(2,3),
			\bpfmix, 1,
			\freq, (Scale.lydian.degrees+69).choose.midicps * [1,2].choose,
			\rq, exprand(0.001,0.008),
			\rate, exprand(0.6,1.2),
			\pan, rrand(-0.5,0.5),
			\amp, exprand(4,6),
		]
	);
};
)

Certainly we could keep playing around with this SynthDef, and tweaking it, and if you're following along feel free to do so, but I'm actually going to call it done, and now turn our focus to our collection of sound files. We've only read three files into SC, but as you can see we have quite a few more. And I think whenever you're dealing with sound file playback, you ought to devote some attention to effectively managing your sound file library. So, just to give you a sense of what's actually in here: In crotales, we have a pair of simple hits... and the others are a crotale disc being struck while resting upside down on a brake drum. This desk bells folder was featured in tutorial 8, it's just a simple chromatic scale from C to C, and shakers in addition to the three sustained sounds we already heard, also includes several short sounds. So, what we'd like to do is to read all these sound files into buffers, ideally using an efficient programming style that allows us to easily and intuitively access individual sounds.

Since the focus here is on composing a piece, the first thing I'm going to do is create a project folder, let's call it Tutorial Piece, and this is where we're gonna store all our composition-related resources, because having everything all in one place is nice and convenient. So let's save this current SuperCollider file in this folder, and move our buffers folder there as well.

As we saw just now and in tutorial 8, the most basic way to read a sound file into memory is with Buffer.read. With one or two files I think this approach is fine, but of course, when lots of files are involved, which is often the case for me, this approach becomes very tedious and inelegant. And what's worse, if you add new audio files, or take some away, or if file names change, that means you've got to go back to your code and edit that too.

In tutorial 8 we briefly saw a more efficient approach for reading multiple sound files involving iteration, and we're going to revisit some of those ideas now. But there's a slight difference-- in tutorial 8, we dealt with one single folder containing sound files, but here, we have three subfolders, each containing audio files, all contained within a single parent folder. So although yes, we could just dump all these audio files into one big SuperCollider array, but then we'd lose our nice organizational scheme, so instead what I'd really like to do is to mirror this organization of folders in SuperCollider, and to do that I'm going to use a class called Dictionary.

Dictionary

Dictionary and Array are both types of Collections, used for storing multiple things, but the difference is that Array is an ordered collection, where each item is associated with an integer index, and Dictionary is an unordered collection, where each item is associated with a unique name. I think dictionary is a more elegant and intuitive choice for buffer management, because it enables us to refer to things by name, rather than a numbered index. For example, if b is our parent folder,

b[\shakers]

is a lot more meaningful to us than

b[2]

Here's the essential syntax for creating and filling a dictionary. We start with a new dictionary,

d = Dictionary.new;

and to fill the dictionary we use the add method, providing a name as a symbol, followed by this hyphen-greater-than construction, which looks like a little arrow, and the value we want to associate with that symbol.

d.add(\foo -> 10);
d.add(\bar -> 20);

So in this case, we've stored two integers in this dictionary, 10 and 20, integer 10 is associated with the symbol foo, and 20 with bar. So now if we evaluate

d[\bar]

SuperCollider returns 20.

With that basic introduction out of the way, let's remove our buffers from the server and start fresh by creating a new Dictionary.

Buffer.freeAll;

(
b = Dictionary.new;
)

So here's what I'm envisioning, b, our Dictionary, will represent our parent folder, called buffers, and so b will contain three Arrays, each representing a corresponding subfolder. And each of the three Arrays will be associated with a symbol determined by the name of the corresponding subfolder. So when we're done, the code

b[\shakers][0]

will refer to the first sound file in the shakers folder,

b[\crotales][2] will refer to this file here, etc.

The first thing we need to do is grab the path to our parent folder.

(
b = Dictionary.new;
"/Users/eli/Desktop/Tutorial Piece/buffers/"
)

And what we have here is just a plain old string, and as such, we can't do very much with it, but we can create a new instance of PathName, which provides us with an arsenal of useful methods for accessing files and folders.

(
b = Dictionary.new;
PathName.new("/Users/eli/Desktop/Tutorial Piece/buffers/");
)

The entries method returns an Array of PathNames corresponding to the items inside the parent folder...as expected there are three entries.

(
b = Dictionary.new;
PathName.new("/Users/eli/Desktop/Tutorial Piece/buffers/").entries;
)

And here's where iteration comes into play. We're gonna use do to iterate over these three subfolders, and on each pass, evaluate a function with an input argument representing the current subfolder pathname instance.

(
b = Dictionary.new;
PathName.new("/Users/eli/Desktop/Tutorial Piece/buffers/").entries.do{
	arg subfolder;
};
)

Each time this function gets evaluated, we want to add a new entry to the dictionary. And we want to use the name of the subfolder as the associative symbol. To do this we take our subfolder argument dot folder name dot as symbol.

(
b = Dictionary.new;
PathName.new("/Users/eli/Desktop/Tutorial Piece/buffers/").entries.do{
	arg subfolder;
	b.add(
		subfolder.folderName.asSymbol ->

	);
};
)

And stored at this symbol, we want to fill a new Array with buffers using the sound files in the current subfolder. Array dot fill needs to know the desired size of the Array, in other words, how many audio files are in the subfolder, so here we can just say subfolder.entries.size, and then a filling function which is evaluated a number of times as determined by the declare array size -- so we're actually doing iteration within iteration here-- and all we need to do in this filling function is declare an argument, which will represent an integer index for each audio file, and then, finally, read an audio file into a buffer. To get the proper path name for each sound file, we get the subfolder entry at index i, this construction will read each audio file, one by one, in I believe alphabetical order, into the array, and then we also need to use the fullPath method, which converts an instance of pathname to a string representing the full absolute path to the file. And that's it, so let's evaluate.

(
b = Dictionary.new;
PathName.new("/Users/eli/Desktop/Tutorial Piece/buffers/").entries.do{
	arg subfolder;
	b.add(
		subfolder.folderName.asSymbol ->
		Array.fill(
			subfolder.entries.size,
			{
				arg i;
				Buffer.read(s, subfolder.entries[i].fullPath);
			}
		);
	);
};
)

So now, b is a Dictionary

b.class;

with size 3, as we would expect

b.size;

and the three associative symbols have been generated according to the names of our three subfolders.

b.keys;

Which means we now have a unified organized collection of sound files which we can access easily and intuitively. For example, here's the crotale file at index 0,

b[\crotales][0].play;

Here's a crotale disc on a brake drum

b[\crotales][2].play;


a few desk bell sounds


b[\deskBells][8].play;
b[\deskBells][10].play;
b[\deskBells][12].play;

and some of our short shaker samples

b[\shakers][2].play
b[\shakers][3].play
b[\shakers][4].play

And just to reinforce the organizational mirroring here, back on the desktop, here's shaker sounds with index 2 3 and 4.

So if we revisit our previous sound example, our sustained shaker sounds have index 5 6 and 7, so we change the buf argument to ask for b at shakers at a randomly chosen value from 5 6 or 7.

(
rrand(4,10).do{
	Synth(
		\bpfbuf,
		[
			\buf, b[\shakers][[5,6,7].choose],
			\atk, exprand(2,3),
			\sus, 0,
			\rel, exprand(2,3),
			\bpfmix, 1,
			\freq, (Scale.lydian.degrees+69).choose.midicps * [1,2].choose,
			\rq, exprand(0.001,0.008),
			\rate, exprand(0.6,1.2),
			\pan, rrand(-0.5,0.5),
			\amp, exprand(4,6),
		]
	);
};
)

And let's not ignore the fact that we can use this SynthDef to play any of our sound files, now that they're all loaded onto the server. So here's a crotales sample starting at the point where it's sort of rattling around noisily on the brake drum,

(
Synth(
	\bpfbuf,
	[
		\buf, b[\crotales][2],
		\atk, 1,
		\rel, 1,
		\spos, 30000,
	]
);
)

Maybe, pitch-shifted down an octave.

(
Synth(
	\bpfbuf,
	[
		\buf, b[\crotales][2],
		\atk, 2,
		\rel, 2,
		\spos, 30000,
		\rate, 0.5,
	]
);
)

And let's create five Synths at once with slightly varying start times and slightly varying playback rates:

(
5.do{
	Synth(
		\bpfbuf,
		[
			\buf, b[\crotales][2],
			\atk, 2,
			\rel, 2,
			\spos, rrand(30000,35000),
			\rate, 0.5 * exprand(0.98,1.02),
		]
	);
};
)

which gives us sort of a chorus effect.

Ok so regarding this nested iteration buffer-reading code we just created, if you consider yourself to be sort of new to programming or new to SuperCollider, I could definitely understand if it just looks sort of really confusing, and on first glance it's probably not the easiest thing in the world to digest. But if it doesn't make total sense now, I'd suggest going over this part of the video a few times and trying it out yourself with a similarly structured collection of your own audio files, and I think you'll find that this kind of approach is really very preferable to writing out 20 or 30 Buffer.read statements. And, keep in mind, a maybe not-so-obvious benefit to this approach is that on your hard drive you can add sound files, remove sound files, change file names, and even add more subfolders, and as long as you don't change the name or location of the parent folder, this code will work like a charm, every time. And even if you do change the parent folder name or location, you only have to change this one line of code. And there's even a way around this problem, which we'll see in the next video.

Ok, so, moving on, let's make another SynthDef. The two that we already have both generate a signal, so let's make a SynthDef that processes an input signal, and specifically we're going to make a reverb effect from scratch.

And first let's take a moment to talk about what reverb actually is. Reverberation is the result of sound waves propagating in an enclosed space primarily reflecting off the walls, floor and ceiling, and all of these different reflections reach our ears at slightly different times, but usually fuse into one big reverberant sound that's audible for all of maybe 2 seconds or so, depending on the space. So, from a signal processing point of view, we can think of reverberation as the sum of many different feedback delays, in which the delay parameters are determined by the size, shape, and building materials of some imagined indoor space.

So in most reverb effects we there's a so called dry signal, which is the unprocessed input signal, and the wet signal, which has the effect applied to it. So we'll declare two variables called dry and wet. I'm also going to need a third variable which I'll called temp, and this is going to be a sort of temporary signal which gets overwritten several times in succession as we create the delay lines and sum them together. And we'll also declare a varialble called sig, which will be our true output signal, some balance between dry and wet.

And now we're gonna get into some topics which we covered in tutorial 7 involving busses, and sharing an audio signal between multiple Synths. We first establish our dry signal using In.ar, which reads an input signal from some audio bus, we'll give it the argument name in, and we'll deal with actually reserving an audio bus a little bit later, and we also need the number of input channels, and for this we specify 2, because so far all our source SynthDefs are stereophonic. And we'll also read this input signal into temp. And we're going to do all sorts of operations with temp, but we'll leave dry alone so that we can mix it back in to the output signal later. And wet will initially be digital silence, so we set it equal to zero. Otherwise it has a value of nil, and we need wet to have some value so that we can do mathematical operations with it later. Technically we could also initialize it to zero DC offset, or the very fancy silent UGen, but, come on, seriously, zero is fine.

DC.ar(0)!2

Silent.ar(2);

Ok and most reverb effects also have something called pre-delay, and this is the amount of time that elapses between our perception of the so-called direct sound, or the sound that travels in a straight line from the source to your ears, and our perception of the first audible reflections, usually where a sound bounces off one or two walls and then hits your ear. And of course this is gonna depend on where you're sitting relative to the source in this theoretical space, and how big the space is, and so on. But, I don't know I guess 0.1 is sort of a reasonable value, but you could definitely experiment with making this value a little smaller or a little bigger.

So now we're ready to start creating and summing a bunch of feedback delays. So we're going to rely on yet another iterative construction using our good friend do, and I've settled on 16 feedback delays, but you can definitely play around with this number. And inside our iterative loop, on each of these 16 passes, we're going to send temp through a UGen called AllpassN, and an allpass filter is basically a delay line with feedback. The N stands for no interpolation applied to the delay time, and there's also AllpassL and AllpassC for linear and cubic interpolation. But no interpolation is the most efficient of the three, and it's absolutely fine in this case, because we're only going to be dealing with fixed delay times, so no interpolation is necessary.

So, uh, sound travels pretty fast, so reflections in a closed space are usually very quick, so we're gonna give our allpass filter a maximum delay time of 50 milliseconds, and for our actual delay time, we're going to choose a unique stereo pair of delay times on each of these 16 evaluations, somewere between one millisecond, and 50 milliseconds. And the fourth argument for allpass is the decay time, essentially this is our reverb time, or the time it'll take our input sound to drop by 60 decibels. And I'm going with a default reverb time of 1.8 seconds, for no particular reason, so feel free to change this value as well.

In a lot of real-world cases, high frequencies tend to get absorbed more readily than low frequencies, especially with things like carpet and curtains and other soft squishy materials, so using a lowpass filter can help simulate this effect and give more emphasis to lower and midrange frequencies-- a lot of people would probably say this creates a warmer or darker sound. In reverb software this is often called damping, and here I'm going to set a cutoff frequency of 4.5 kilohertz. And for the last step in our loop, we're going to add this delay line to our wet signal. So these three things happen 16 times in a row, and at the end of it, wet is the sum of 16 lowpass filtered stereo feedback delays, each with a uniquely generated, and considerably short delay time, and each with a 1.8 second decay time.

After closing out this loop, we'll use XFade2 to blend between the dry and wet, just like we did with the previous SynthDef, and again use our *2-1 feature so we can specify a mix value between 0 and 1. And here I'll also apply a master amplitude argument. Probably we won't ever adjust this argument, but it's never really a bad idea to have the option to shut something off completely. And, we're done! So output the signal, close the UGen function and add the SynthDef.

(
SynthDef(\reverb, {
	arg	in=0, predelay=0.06, revtime=1.8, lpf=4500, mix=0.15, amp=1, out=0;
	var dry, wet, temp, sig;
	dry = In.ar(in, 2);
	temp = In.ar(in, 2);
	wet = 0;
	temp = DelayN.ar(temp, 0.2, predelay);
	16.do{
		temp = AllpassN.ar(dry, 0.05, {Rand(0.001,0.05)}!2, revtime);
		temp = LPF.ar(temp, lpf);
		wet = wet + temp;
	};
	sig = XFade2.ar(dry, wet, mix*2-1, amp);
	Out.ar(out, sig);
}).add;
)

To put our reverb into action, we need to declare a 2 channel audio bus, because that's the kind of signal we'll be generating, and that's done with Bus.audio, giving the name of the server and the number of channels.

~reverbBus = Bus.audio(s,2);

And then let's instantiate our reverb

~reverbSynth = Synth(\reverb, [\in, ~reverbBus]);

And there it is, on the node tree. And for a source sound, let's just do a short shaker sound with a little randomness in release time and playback rate. By default, the output bus is zero, which bypasses the reverb completely

(
Synth(
	\bpfbuf,
	[
		\buf, b[\shakers][(0..4).choose],
		\rel, rrand(0.15,0.25),
		\rate, rrand(-2.0,2.0).midiratio,
	]
);
)

But if we set the reverb bus as the output destination...we hear reverb.

(
Synth(
	\bpfbuf,
	[
		\buf, b[\shakers][(0..4).choose],
		\rel, rrand(0.15,0.25),
		\rate, rrand(-2.0,2.0).midiratio,
		\out, ~reverbBus
	]
);
)

Just to revisit a few ideas from tutorial 7, whenever one Synth is passing a signal to another Synth, the sending Synth must be above the receiving Synth in the node chain. And so here I'm taking advantage of the fact that whenever a new Synth is created, by default it gets put at the top, or head of the node tree, and since I created the reverb Synth first, everything created after it will conveniently always be placed at the head of the tree, and therefore above the reverb Synth, and that's exactly what we want. If these ideas are unfamiliar to you then I encourage you to check out tutorial 7.

Let's make a pattern real quick.

(
p = Pbind(
	\instrument, \bpfbuf,
	\dur, Pexprand(0.1,1),
	\buf, Pxrand(b[\shakers][(5..7)]++b[\deskBells][(0..2)],inf),
	\spos, Pwhite(10000,40000),
	\rel, Pexprand(0.01,0.5),
	\rate, Pwhite(-7.0,7.0).midiratio,
	\amp, Pexprand(0.5,0.9),
	\out, ~reverbBus,
).play;
)

p.stop;

And remember that even our output bus can be subject to pattern control. With something like this, we can randomly cause some synths to bypass the reverb

(
p = Pbind(
	\instrument, \bpfbuf,
	\dur, Pexprand(0.1,1),
	\buf, Pxrand(b[\shakers][(5..7)]++b[\deskBells][(0..2)],inf),
	\spos, Pwhite(10000,40000),
	\rel, Pexprand(0.01,0.5),
	\rate, Pwhite(-7.0,7.0).midiratio,
	\amp, Pexprand(0.5,0.9),
	\out, Prand([0,~reverbBus],inf),
).play;
)

p.stop;

To make this effect even more audible, let's crank up the mix on our reverb Synth.

~reverbSynth.set(\mix, 1);
//let run for awhile

So here we are, a few SynthDefs created, a few Synths running on the server, maybe a pattern or two playing, and as you're experimenting, if you're like me, you will invariably, instintively hit command period.

Ok, seems fine, and let's say we want to go back to our original pattern where all Synths go through the reverb. Play this Pbind, and...

(
p = Pbind(
	\instrument, \bpfbuf,
	\dur, Pexprand(0.05,1),
	\buf, Pxrand(b[\shakers][(0..4)],inf),
	\rel, Pwhite(0.15,0.25),
	\rate, Pwhite(-2.0,2.0).midiratio,
	\amp, Pexprand(0.4,0.9),
	\out, ~reverbBus,
).play;
)

p.stop;

... we hear nothing. Of course this is because command period doesn't just stop our pattern, it stops all patterns and frees all the Synths from the server, that includes our reverb. And so initially, you may think well that's dumb, now I have to re-instantiate the reverb every time I hit command period.

p.stop;

And while yeah, that would work, it would also be really annoying, which is why there's a very good solution to this issue, and it involves the use of a class called ServerTree.

Unlike a lot of other objects in SuperCollider, you don't create new instances of ServerTree. Instead, ServerTree acts sort of like a one-stop repository where you can register one or more functions to be evaluated whenever the server is reset to its initial state. And really this is a perfect tool for automating certain processes that you want to happen whenever the server gets cleared, like, for example instantiating a reverb effect.

So let's make a function called createReverb, and what this function is going to do, when evaluated, is just create one instance of our reverb synth.

~createReverb = {~reverbSynth = Synth(\reverb, [\in, ~reverbBus])};

And then we register this function by adding it to ServerTree.

ServerTree.add(~createReverb);

And now, whenever we press command period, and watch the node tree here... this reinitializes the server, which is ServerTree's cue to evaluate all of its registered functions. And this means a new reverb Synth is created for us, automatically.

So now we can play our Pbind again...

(
p = Pbind(
	\instrument, \bpfbuf,
	\dur, Pexprand(0.05,1),
	\buf, Pxrand(b[\shakers][(0..4)],inf),
	\rel, Pwhite(0.15,0.25),
	\rate, Pwhite(-2.0,2.0).midiratio,
	\amp, Pexprand(0.4,0.9),
	\out, ~reverbBus,
).play;
)

Wonderful, we hear sound...And just to show this off again, I'm gonna hit command period again...

And this stops the sound, but also invokes ServerTree, and so a brand new reverb Synth is ready and waiting for us.

(
p = Pbind(
	\instrument, \bpfbuf,
	\dur, Pexprand(0.05,1),
	\buf, Pxrand(b[\shakers][(0..4)],inf),
	\rel, Pwhite(0.15,0.25),
	\rate, Pwhite(-2.0,2.0).midiratio,
	\amp, Pexprand(0.4,0.9),
	\out, ~reverbBus,
).play;
)

So, very convenient. And if you ever want to remove all the registered functions from ServerTree, we can just type

ServerTree.removeAll;

And now, hit command period, and our reverb synth is no longer automatically created.

That's it for tutorial 16. In the next video we'll more or less continue from here and close out this three part series, introducing a few more concepts, and getting into some more details. We might add another SynthDef or two, and we'll revisit ServerTree as well as its parter classes ServerBoot and ServerQuit, but mostly we'll focus on putting all these elements together and build a sequence of musical event functions that provide a means of performing a short composition. Until then, I hope you enjoy messing around with what you've seen in this video, and maybe develop a few SynthDefs on your own. So, thanks for watching, and see you next time.