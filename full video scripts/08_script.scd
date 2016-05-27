 Hey everyone, welcome to tutorial number 8. In this video I'll discuss the Buffer object

[open buffer help file]

and demonstrate some of its common uses. So far, the audio examples in this series have focused on generated sound, like sine waves, sawtooth waves, white noise, and so forth. But we haven't really dealt with recorded sound yet, and for this we use Buffers. Generally speaking, a buffer corresponds to a location in your computer's memory that's used to hold an ordered sequence of values. In the context of digital sound, buffers are usually used for holding, recording, and playing back sampled audio. So let's jump right in.

Buffers are server-side objects, so we'll need to boot the audio server before we can do anything useful.

s.boot;

To load an audio file into a buffer, you can use the "read" method, which allocates a buffer on the audio server, and reads your soundfile into it.

[search help for "read" open Buffer help file]

At minimum, read expects two arguments. The first argument is the server onto which the buffer will be loaded. In this case, and in most cases, this is the local audio server, stored in the global variable s.

~b0 = Buffer.read(s, )

The 2nd argument is a String that represents the path of your sound file. On my desktop, I've got a folder called sounds, which has a few sound files I'll use for this tutorial. And this is a good time to point out that your sound files should be in either aif or wav format. I'll load the file called car1, which sounds like this, and I happen to know that the path for this file is /Users/eli/Desktop/sounds/car1.aiff. Remember that a string is delineated by an enclosure of double quotes, and also make sure to use exact spelling and capitalization.

~b0 = Buffer.read(s, "/Users/eli/Desktop/sounds/car1.aiff");

Ok, so let's stop here and run this line. In the post window, this is what you can expect to see if you've done everything correctly. If you misspell your path name, SuperCollider will let you know.

As a convenience, we can use the play method to hear the contents of a buffer.

~b0.play

But with this approach, all you can really do is verify that your sound file has been loaded successfully.

It's also important to know how clear and remove buffers, once you've created them. If you want to clear the contents of a buffer, but not remove it from the server, we can use the "zero" message. Now, if we play ~b0, all we hear is silence.

~b0.zero;
~b0.play;

We've cleared b0, but we haven't removed the allocated buffer from the server, so we can fill it with sound once again, using the read method on the allocated buffer, like this

~b0.read("/Users/eli/Desktop/sounds/car1.aiff");
~b0.play;

If you want to remove a buffer from the server entirely, we use "free", just like with Synths and Groups.

~b0.free;

Now this buffer's completely gone, so if we try to play it

~b0.play;

Or read a file into it

~b0.read("/Users/eli/Desktop/sounds/car1.aiff");

We get an error message.

And since we're on the topic of freeing buffers, if you ever want to remove ALL allocated buffers and start with a clean slate, you use the class method "freeAll", like this

Buffer.freeAll;

So that more or less covers the basics of adding and removing buffers. So let's get that sound back. Now, if you're like me, you'll get really tired, really fast, of having to type a long string every time you want to read an audio file into a buffer, especially if your sound is buried 12 folders deep and, you know, has a really long path name. So I'm going to demonstrate a useful shortcut.

~b0 = Buffer.read(s, );

Instead of manually typing the path, you can drag and drop a soundfile into the editor, and it'll be automatically be converted into a string representing its path.

~b0 = Buffer.read(s, "/Users/eli/Desktop/sounds/car1.aiff");
~b0.play;

And while I'm at it, I'll also load car2, car3, and bike into their own buffers

~b1 = Buffer.read(s, "/Users/eli/Desktop/sounds/car2.aiff");
~b2 = Buffer.read(s, "/Users/eli/Desktop/sounds/car3.aiff");
~b3 = Buffer.read(s, "/Users/eli/Desktop/sounds/bike.aiff");

~b1.play;
~b2.play;
~b3.play;

Ok, cool, so now that we've got a few sound files loaded, let's talk about some fundamental attributes of buffers. First, every buffer has a certain number of frames, and this number corresponds to the length of the buffer. If you want to know the number of frames in a buffer, we just use the numFrames method.

~b0.numFrames;

We can see that buffer b0 has 132313 frames. Frames are similar to samples, but not quite the same. To illustrate the difference, I'll segue into another fundamental attribute, which is channels. Like frames, every buffer has a certain number of channels.

~b0.numChannels;

Using the numChannels method, we can see that b0 has 2 channels. This is because the original audio file is a stereo file, and therefore has two channels. The read message detects this and automatically allocates a buffer with the same number of channels. So here's the difference between samples and frames. In the case of a mono buffer, or in other words, a one-channel buffer, the number of samples is the same as the number of frames. With a stereo buffer, there are two channels, so there are actually twice as many samples as there are frames. Buffers can have any number of channels, actually, not just 1 or 2, so the equation to remember is

numSamples = numFrames * numChannels

As we'll see later on, it's important to be aware of how many channels you're dealing with, because Buffer UGens won't work correctly if you're inconsistent when specifying the number of channels you're working with.

Speaking of monophonic buffers, let's take a quick detour before we continue talking about fundamental attributes of buffers. Suppose we have a stereo sound file, but we only want to read one of the the two channels into a buffer. We can do this using the readChannel method, which is almost the same as the read method, but includes an additional argument for specifying the number of channels

~b4 = Buffer.readChannel(s, "/Users/eli/Desktop/sounds/car1.aiff", channels:[0]);

Channels is specified as an array. The array [0] will read the 1st channel, usually considered the left channel, and the array [1] will read the other channel.

s.meter;

Now if we take a look at the level meters, we see that buffer b0 plays out of both speakers, since we've loaded a stereo file into it.

~b0.play;

But buffer b4 is a one-channel buffer

~b4.numChannels;

So we only see and hear one channel of audio.

~b4.play;

Ok, moving on to more fundamental attributes, if you ever need the length of a buffer in seconds, you can use the duration method, like this

~b2.duration;

so that's pretty straightforward.

One very common and important attribute is Buffer Numbers. Whenever a buffer is loaded onto the server, using read, readChannel, or any other method of buffer allocation, SuperCollider assigns to it a buffer number, or bufnum, as it's more commonly called. Bufnums are integers starting with zero that are automatically assigned in ascending order when a Buffer is created. If you want to get the bufnum for a particular buffer, we use the method bufnum.

~b0.bufnum;
~b1.bufnum;
~b2.bufnum;
~b3.bufnum;

We can see that the bufnums have been assigned according to the order in which we created these buffers. Bufnums might not always be in perfect ascending order, depending on how and when you create and remove buffers, but as we'll see later on, you don't really have to worry about how SuperCollider assigns bufnums. The important thing to remember is that, at any given moment, each buffer on the server has a unique integer associated with it, and that you can get that integer using the bufnum method.

The last attribute I'll cover is the buffer sample rate. All sound files are recorded and exported at a certain sample rate, and buffers reflect these sample rates.

~b0.sampleRate;

the audio file in buffer b0, and in fact all the other sounds in this folder, have been exported at 44100 samples per second

s.sampleRate;

and the server sample rate is the same, so I'm in good shape. It is possible to have buffer sample rates that are different than the server sample rate, so long as you're aware of the difference, and take the correct measures, so that your sounds aren't unintentionally re-sampled. We'll deal with this a little bit later.

In summary, you can use the query message as a quick and convenient way to see many of these fundamental attributes all at once.

~b0.query;

So that's about it for buffer fundamentals. There are two things I'd like to talk about before we get into buffer UGens: 1 is how to read only part of a soundfile into a buffer, and 2 is how to read many soundfiles onto the server at once.

To read part of a soundfile into a buffer, we can use the 3rd and 4th arguments of the read method, startFrame and numFrames. To demonstrate, I'll revisit the motorcycle sound, which is currently stored in buffer ~b3.

~b3.play;

So, suppose I only want to read the first half second of this sound file. I'll specify 0 as the starting frame, and for the number of frames, I can just specify half the server's sample rate

~b3_part0 = Buffer.read(s, "/Users/eli/Desktop/sounds/bike.aiff", 0, s.sampleRate/2);
~b3_part0.play;

Alternatively, let's say I want to read just the tail end of this soundfile. First I'll check the number of frames in the buffer containing the full sound file,

~b3.numFrames;

which is 264599. I'll pick an arbitrary start frame somewhere close to the end, and use simple subtraction to determine the number of frames between this frame and the end. However, because the index of the first frame is zero, not one, this means the index of the last frame is actually the total number of frames minus one, so the responsible thing to do here is to subtract an extra frame. Technically, this might not be necessary - There's a chance SuperCollider might anticipate this error and handle it for us, but even so, it feels like a safe thing to do.

~b3_part1 = Buffer.read(s, "/Users/eli/Desktop/sounds/bike.aiff", 223555, ~b3.numFrames-223556);
~b3_part1.play

So let's talk about how to load many sound files all at once, instead of having to type them one at a time. There are, in fact, lots of different ways to do this, and most of them involve some kind of iteration. One fairly simple option is to store your sound files in an Array, so that each buffer is addressable by a unique index. For this example I'll use a folder containing a chromatic scale of desk bells.

And I'll start by creating an empty Array, which will be used to hold our buffers:

~bells = Array.new;

and I'm also going to use an instance of a class called PathName that acts as a reference to the folder of bell sounds.

~folder = PathName.new("/Users/eli/Desktop/sounds/bells/");

If you send the message "entries" to a PathName, it will return an Array of PathNames representing the soundfiles themselves.

~folder.entries;

Now all I have to do is iterate over the folder entries using do, similar to what we saw in tutorial 6. I'll iterate over these paths and on each iteration, I'll add a Buffer to the Array, using the current path. I'll need to use the method called fullPath to convert a PathName into a String.

(
~folder.entries.do({
	arg path;
	~bells = ~bells.add(Buffer.read(s, path.fullPath));
});
)

And that's really all there is to it. We can see that ~bells is now filled with buffers, and we can refer to inidividual buffers using the 'at' method, like this

~bells;
~bells.at(0).play;
~bells.at(4).play;
~bells.at(7).play;
~bells.at(12).play;

Even quicker is the syntactical shortcut using square brackets:

~bells[12].play;

Keep in mind that there is a limit on the number of buffers you can load onto the server, which you can get by evaluating

s.options.numBuffers;

The default is 1024, but if you need more than that, you can change the maximum number of buffers by setting this attribute equal to a new value,

s.options.numBuffers = 2000;

evaluating this line, and rebooting the server, which I won't actually do because I don't need to. And, if you find yourself loading a really substantial amount of sound files, you'll probably see the server become inactive for several seconds, and these green numbers will turn white to indicate this, and the server will come back online when it's done. And this is normal because that's what happens when you slamm scsynth with hundreds of commands all at once.

So that about covers buffer fundamentals. Let's now turn our attention to manipulating Buffers with UGens. There are two UGens commonly used for buffer playback: PlayBuf, and BufRd. The main difference between these two is that PlayBuf will read through a buffer automatically according a given playback rate, whereas BufRd doesn't have a rate argument and instead relies on an audio-rate pointer into the buffer for sample playback.

I'll deal with PlayBuf first, and I'll create a SynthDef to demonstrate. At minimum, PlayBuf needs to know two things about the buffer it's playing: the number of channels, and the bufnum. Since I'm only going to be dealing with stereo sound, I'll specify two channels. For the bufnum, it's possible to provide the bufnum explicitly, like this,

(
SynthDef.new(\playbuf_test, {
	arg amp=1, out=0;
	var sig;
	sig = PlayBuf.ar(2, ~b0.bufnum);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

But of course, this is a poor choice, because it means this SynthDef will only be able to play buffer b0. Much better is to declare a bufnum argument, and specify the bufnum when the Synth is created, like this.

(
SynthDef.new(\playbuf_test, {
	arg amp=1, out=0, buf;
	var sig;
	sig = PlayBuf.ar(2, buf);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

Synth.new(\playbuf_test, [\buf, ~b0.bufnum]);

Now we can use the same SynthDef to play different buffers:

Synth.new(\playbuf_test, [\buf, ~b1.bufnum]);
Synth.new(\playbuf_test, [\buf, ~b2.bufnum]);

On the other hand, it's NOT possible to declare an argument for the number of channels, as we can see from this error message.

(
SynthDef.new(\playbuf_test, {
	arg amp=1, out=0, chan=2, buf;
	var sig;
	sig = PlayBuf.ar(chan, buf);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

The reason for this is that the number of audio channels in a SynthDef can't change dynamically, and instead has to be a fixed, known quantity when the SynthDef is compiled, so the numChannels argument can't be modulated.

Another common pitfall can arise when the number of channels of the PlayBuf doesn't match the number of channels in the buffer.

(
SynthDef.new(\playbuf_test, {
	arg amp=1, out=0, buf;
	var sig;
	sig = PlayBuf.ar(2, buf);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

Synth.new(\playbuf_test, [\buf, ~b4.bufnum]);

Here I'll try to play buffer b4, which is monohponic, and SuperCollider reacts with a polite message that the number of channels don't match. But don't get used to this courtesy, because there are many situtaions in which a buffer channel mismatch will cause a Synth to fail silently, without any indications or any error messages.

Ok, so let's develop our SynthDef some more. To continue, let's take a look at the node tree, where we can see that even though we're not hearing anything at the moment, we've got a pile of Synths that have built up on the server. So first things first, let's clear out this junk with s.freeAll.

s.plotTree;

s.freeAll;

So what were all those Synths doing on the server? As it turns out, just like EnvGen from tutorial number 4, PlayBuf has an inherently finite duration, and therefore has a doneAction associated with it. When PlayBuf reaches the end of the buffer, it checks its doneAction to determine what kind of action to take. The default value is zero, which means, when PlayBuf finishes, it takes no action, and just sits on the last frame indefinitely.

If you want the Synth to free itself after it's done playing, you should specify doneAction:2. In fact, I'll declare an argument for doneAction so that we'll have the option to choose different types for different situations.

(
SynthDef.new(\playbuf_test, {
	arg amp=1, out=0, buf, da=2;
	var sig;
	sig = PlayBuf.ar(2, buf, doneAction:da);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

Now, this Synth will free itself automatically when PlayBuf is finished.

Synth.new(\playbuf_test, [\buf, ~b0.bufnum]);

Let's add an argument for the playback rate.

(
SynthDef.new(\playbuf_test, {
	arg amp=1, out=0, buf, rate=1, da=2;
	var sig;
	sig = PlayBuf.ar(2, buf, rate, doneAction:da);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

Rate is interpreted as a ratio, so 1 is the normal sample rate, 2 would be twice as fast,

Synth.new(\playbuf_test, [\buf, ~b0.bufnum, \rate, 2]);

and 0.5 would be twice as slow.

Synth.new(\playbuf_test, [\buf, ~b0.bufnum, \rate, 0.5]);

However, simply specifying the playback rate with number isn't fool proof, and this has to do with Buffer sample rates which I mentioned earlier. For instance, if your buffer sample rate is different from the server sample rate, the buffer will be resampled, and you won't get the results you might expect. To demonstrate, I've got a modified copy of car1 that's been exported at 96k samples per second

~b0_96k = Buffer.read(s, "/Users/eli/Desktop/sounds/car1_96k.aiff");

as we can verify with the query message.

~b0_96k.query;

But if we play this buffer using our SynthDef, specifying a rate of 1, PlayBuf resamples the buffer to fit the server sample rate, which causes a pitch and time shift

Synth.new(\playbuf_test, [\buf, ~b0_96k.bufnum, \rate, 1]);

The most sensible way to deal with this problem is to use one of several convenience UGens designed to access a buffer's attributes. In the Help Documentation, we can find these UGens under Browse, UGens, Buffer, and Info. In this case, we want to use BufRateScale, which outputs a ratio based on the buffer and server sample rates, so that the buffer will playback at its original speed. BufRateScale, and these other five info UGens, only need one argument- the bufnum for the appropriate buffer.

(
SynthDef.new(\playbuf_test, {
	arg amp=1, out=0, buf, rate=1, da=2;
	var sig;
	sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * rate, doneAction:da);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

Now, our SynthDef can handle buffers with different sample rates, and the rate argument behaves consistently.

Synth.new(\playbuf_test, [\buf, ~b0_96k.bufnum, \rate, 1.5]);
Synth.new(\playbuf_test, [\buf, ~b0.bufnum, \rate, 1.5]);

Getting back to PlayBuf, trigger and startPos allow you to specify a start frame and give the option of jumping to that frame by sending a trigger. Keep in mind that if doneAction is 2 and PlayBuf reaches the end of the buffer, the Synth will free itself and therefore won't be triggerable.

(
SynthDef.new(\playbuf_test, {
	arg amp=1, out=0, buf, rate=1, t_trig=1, start=0, da=2;
	var sig;
	sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * rate, t_trig, start, doneAction:da);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

This particular Synth will start half a second after the beginning, and won't free itself if it gets to the end.

x = Synth.new(\playbuf_test, [\buf, ~b0.bufnum, \start, s.sampleRate * 0.5, \da, 0]);

We can jump to the start position like this:

x.set(\t_trig, 1);

x.free;

Loop is the last argument we haven't talked about. If loop is set to 1, PlayBuf will loop through the buffer and ignore its doneAction.

(
SynthDef.new(\playbuf_test, {
	arg amp=1, out=0, buf, rate=1, t_trig=1, start=0, loop=0, da=2;
	var sig;
	sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * rate, t_trig, start, loop, da);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

x = Synth.new(\playbuf_test, [\buf, ~b3_part1.bufnum, \loop, 1]);

Loop can be changed while the Synth is playing, just like other arguments. If we set loop to zero, the Synth will evaluate its doneAction as soon as PlayBuf reaches the end of the buffer.

x.set(\loop, 0);

To play a sound backward using PlayBuf, we provide a negative rate, and make sure we start at the last frame. But again, keep in mind that to specify the last frame, we need to subtract 1 from the total number of frames becuase the frame indices start with zero.

Synth.new(\playbuf_test, [\buf, ~b0.bufnum, \rate, -1, \start, ~b0.numFrames - 1]);

Ah, but even this doesn't work, and I'll tell you why. We're starting at the last frame of the buffer, which is PlayBuf's cue to check its doneAction, and that happens to be 2. So, this means, when we instantiate this Synth, it actually frees itself immediately. We can correct this by specifying the start position to be one frame earlier.

Synth.new(\playbuf_test, [\buf, ~b0.bufnum, \rate, -1, \start, ~b0.numFrames - 2]);

I want to return to the idea of playback rates for a second, because it needs to be said that ratios are not the most intuitive way to think about pitch, especially if you're interested in chromatic harmony. For this reason there's a method called midiratio, which converts a transposition in semitones into an equal-tempered ratio.

For example, a shift of 12 semitones up would be an octave, so 12.midiratio returns 2

12.midiratio;

Well, almost. but, uh, it's pretty close

Likewise, 12 semitones down returns one half.

-12.midiratio;

A perfect fifth is 7 semitones,

7.midiratio;

so there's the equal tempered ratio for a fifth, and so on.

So with midiratio, it becomes very easy to transpose your sounds by semitones.

Synth.new(\playbuf_test, [\buf, ~bells[0].bufnum, \rate, -7.midiratio]);
Synth.new(\playbuf_test, [\buf, ~bells[0].bufnum, \rate, -10.midiratio]);
Synth.new(\playbuf_test, [\buf, ~bells[0].bufnum, \rate, -13.midiratio]);
Synth.new(\playbuf_test, [\buf, ~bells[0].bufnum, \rate, -15.midiratio]);

So that's essentially how PlayBuf works. Here's a quick example that's a little more interesting and a little less clinical. I'll first create a Group, and put three Synths into it, each with a different buffer and different playback rate, and I'll loop them.

g = Group.new;

(
x = Synth.new(\playbuf_test, [\buf, ~b0.bufnum, \rate, 1.5, \loop, 1, \amp, 0.5], g);
y = Synth.new(\playbuf_test, [\buf, ~b1.bufnum, \rate, 1.2, \loop, 1, \amp, 0.5], g);
z = Synth.new(\playbuf_test, [\buf, ~b2.bufnum, \rate, 2.1, \loop, 1, \amp, 0.5], g);
)

I can change the rate of each of these by sending a message to the enclosing group:

g.set(\rate, 0.8);
g.set(\rate, 0.5);

I can set all three synths to play the same buffer,

g.set(\buf, ~b3_part1.bufnum);

And I can send messages individually. Here I'll randomize the rates so they all fall out of phase with each other.

x.set(\rate, exprand(0.2,2.0));
y.set(\rate, exprand(0.2,2.0));
z.set(\rate, exprand(0.2,2.0));

And I can disable looping for all three synths simultaneously.

g.set(\loop, 0);

Cool, ok let's now turn our attention to BufRd. BufRd starts with the same two arguments as PlayBuf: the number of channels, and the bufnum. The third argument must be an audio rate signal, which will be used as a frame pointer into the buffer. So let's make another variable called pointer.

Suppose we just want to read through this buffer once. The simplest way to do this is to use Line, which goes from point A to point B over a given duration. Remember that the read pointer for BufRd must run at the audio rate, so I'm choosing dot ar. We want to start at the zeroth frame, and travel to the last frame. This is a good opportunity to revisit the Buffer Info UGens. Here we can use BufFrames, making sure to subtract 1, and then for the duration argument, we can use BufDur, to ensure that the Line takes the correct amount of time to travel from start to finish. And for good measure, I'll specify doneAction:2 on the Line so that the Synth will free itself at the end.

(
SynthDef.new(\bufrd_test, {
	arg amp=1, out=0, buf;
	var sig, ptr;
	ptr = Line.ar(0, BufFrames.kr(buf) - 1, BufDur.kr(buf), doneAction:2);
	sig = BufRd.ar(2, buf, ptr);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

Synth.new(\bufrd_test, [\buf, ~b2.bufnum]);

Maybe we want some flexibility in where Line starts and ends. So, I'll declare some arguments.

(
SynthDef.new(\bufrd_test, {
	arg amp=1, out=0, buf, start, end;
	var sig, ptr;
	ptr = Line.ar(start, end, BufDur.kr(buf), doneAction:2);
	sig = BufRd.ar(2, buf, ptr);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

Now we can play the file forward, or backward

Synth.new(\bufrd_test, [\buf, ~b2.bufnum, \start, 0, \end, ~b2.numFrames-1]);
Synth.new(\bufrd_test, [\buf, ~b2.bufnum, \start, ~b2.numFrames-1, \end, 0]);

To loop a buffer, we'll need to choose a UGen other than Line, because Line isn't capable of looping. Phasor is usually an excellent choice for this, because it's a linear ramp oscillator with inputs for start, end, and rate.

I'll just provide a zero for the trigger argument because I don't plan on retriggering Phasor, and go to the second argument, which is rate. And once again, this is a great opportunity to use BufRateScale.

(
SynthDef.new(\bufrd_loop, {
	arg amp=1, out=0, buf, rate=1, start, end;
	var sig, ptr;
	ptr = Phasor.ar(0, BufRateScale.kr(buf) * rate, start, end);
	sig = BufRd.ar(2, buf, ptr);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

x = Synth.new(\bufrd_loop, [\buf, ~b2.bufnum, \start, 0, \end, ~b2.numFrames-1]);

I can change the start and end points, for example, to only read the second half of the file

x.set(\start, ~b2.numFrames/2, \end, ~b2.numFrames-1);

or I can choose a more specific range of frames

x.set(\start, 2000, \end, 26000);

and I can change the rate too, just like I did with PlayBuf

x.set(\rate, -3.midiratio);
x.set(\rate, -7.midiratio);

x.free;

I find that Phasor is usually the right tool for looping through a buffer, but there are a couple alternatives to Phasor, in particular there's Sweep and LFSaw, which you might find useful as a frame pointer in some situations.

But BufRd is even more flexible, because you can use ANY audio rate UGen as a frame pointer, so long as that UGen has an appropriate output range. For example, I can read a buffer forward and backward, sinusoidally by using SinOsc as an audio rate pointer. I'll set the initial phase offset for the sine wave generator to be 3pi/2, so that SinOsc starts at its lowest point, which corresponds to the beginning of the buffer.

(
SynthDef.new(\bufrd_sine, {
	arg amp=1, out=0, buf, freq=0.2, start, end;
	var sig, ptr;
	ptr = SinOsc.ar(freq, 3pi/2).range(start, end);
	sig = BufRd.ar(2, buf, ptr);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

x = Synth.new(\bufrd_sine, [\buf, ~b2.bufnum, \start, 0, \end, ~b2.numFrames-1, \freq, 0.2]);
x.free;

One of my personal favorites, you can use a noise generator as a buffer playback pointer. Using a low frequency noise generator, you'll hear random sections of the soundfile, at random speeds, sometimes forward, sometimes backward.

(
SynthDef.new(\bufrd_noise, {
	arg amp=1, out=0, buf, freq=0.75, start, end;
	var sig, ptr;
	ptr = LFDNoise1.ar(freq).range(start, end);
	sig = BufRd.ar(2, buf, ptr);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

x = Synth.new(\bufrd_noise, [\buf, ~b2.bufnum, \start, 0, \end, ~b2.numFrames-1]);
x.free;

With multiple Synths, each playing a different sound, you can get some interesting layered effects.

w = Synth.new(\bufrd_noise, [\buf, ~b0.bufnum, \start, 0, \end, ~b0.numFrames-1, \freq, 0.6, \amp, 0.5]);
x = Synth.new(\bufrd_noise, [\buf, ~b1.bufnum, \start, 0, \end, ~b1.numFrames-1, \freq, 0.8, \amp, 0.5]);
y = Synth.new(\bufrd_noise, [\buf, ~b2.bufnum, \start, 0, \end, ~b2.numFrames-1, \freq, 0.7, \amp, 0.5]);
z = Synth.new(\bufrd_noise, [\buf, ~b3.bufnum, \start, 0, \end, ~b3.numFrames-1, \freq, 0.5, \amp, 0.2]);

s.freeAll;

The higher the frequency of the noise generator, the faster the playback pointer will move, and it'll give your sound a more chaotic and glitchy sound.

g = Group.new;

w = Synth.new(\bufrd_noise, [\buf, ~b0.bufnum, \start, 0, \end, ~b0.numFrames-1, \freq, 2.5, \amp, 0.5], g);
x = Synth.new(\bufrd_noise, [\buf, ~b1.bufnum, \start, 0, \end, ~b1.numFrames-1, \freq, 3.4, \amp, 0.5], g);
y = Synth.new(\bufrd_noise, [\buf, ~b2.bufnum, \start, 0, \end, ~b2.numFrames-1, \freq, 2.7, \amp, 0.5], g);
z = Synth.new(\bufrd_noise, [\buf, ~b3.bufnum, \start, 0, \end, ~b3.numFrames-1, \freq, 3.3, \amp, 0.2], g);

g.set(\freq, 16);
g.set(\freq, 60);
g.set(\freq, 200);
g.set(\freq, 0.16);

s.freeAll;

That's it for Tutorial number 8. I haven't discussed the flipside of buffer playback, which is buffer recording. PlayBuf and BufRd each have a corresponding UGen designed to write data into a buffer much in the same way that these two UGens read buffer data. They're named RecordBuf, and BufWr, respectively. All of the help files I've visited in this video are worth reading if you'd like to learn more, and as always, I encourage you to experiment. In the next video, I'll talk about SuperCollider's MIDI classes, and give a few demonstrations of how to get SC to communicate with external MIDI devices. I hope you enjoyed this video, and thanks for watching!