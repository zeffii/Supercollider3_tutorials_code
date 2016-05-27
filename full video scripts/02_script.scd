Hey everyone, welcome to tutorial number 2, where we'll start working with sound.

SuperCollider appears as one program, but actually exists as two programs. The language, called sclang, is home to an object-oriented programming language, a library of classes, and the language's interpreter, which reads and parses your code. The other half of SuperCollider is a real-time audio synthesis program called scsynth, which communicates over UDP or TCP using the Open Sound Control protocol, or OSC. The language and the server are abstractly networked and behave according to a "client-server" architecture. The user, operating in the language, acts as a client to the audio server, and makes requests of the audio server by transmitting OSC messages. Because the two programs are networked, one could theoretically manipulate audio on an instance of scsynth running on a laptop halfway around the world, or you could have several clients connected to one audio server, as is the case in some laptop ensemble performances.

If you're interested in a brief introduction to the client-server architecture of SuperCollider, you can read the video description below, and there are some useful reference files in the help documentation, such as

SuperCollider 3 Server Tutorial
Client vs Server
Server Architecture

To make sound on your computer, we first have to boot the local audio server. There are several ways to do this. One is by evaluating

Server.local.boot;

As the server boots, the post window displays some information...Here we can see the available audio devices...the devices that are currently being used for input and output...and the sample rate. These can all be changed very easily, but I won't dive into that right now. At the bottom right of the screen is a small display that gives information about thet status of the language and the audio server. We can see that the interpreter is active, and that the server is humming along, using somewhere between .05 and .1 percent of the computer's CPU.

To quit the audio server, we can evaluate

Server.local.quit;

And we can see in the corner that the server application is no longer running. As a convenience for the user, when SuperCollider starts up, the local server is automatically stored in the global variable s. If we evaluate s, we can see that indeed it keeps a reference to the local server.

s;

Therefore we can alternatively boot the server by evaluating

s.boot;

and quit scsynth by evaluating

s.quit;

s is by convention reserved for the local server, and it's convenient to have it available in a single-character global variable. So even though there's nothing stopping you from overwriting s, I'd recommend not overwriting it.

Lastly, you can boot the server by going to the Language menu and clicking Boot Server. There's a keyboard shortcut for this which I recommend memorizing, since it's the quickest way to launch scsynth. Don't forget that you can customize all these shortcuts in the preferences dialog. If everything's green in the corner, you're ready to make sound.

The quickest and easiest way to make sound in SuperCollider is to create a function, which is delineated by an enclosure of curly braces, fill it with one or more Unit Generators, and send it the "play" message. As a reminder from the previous tutorial, press shift-return to evaluate a single line of code.

{SinOsc.ar}.play;

Before we go any farther, it's absolutely critical that you know how to stop all sound. In the Language menu, there's an option labeled "Stop", but much quicker is the keyboard shortcut, which is command-period. This is by far the most important keyboard shortcut to memorize.

Notice that the post window indicates that we've created a Synth. We'll talk more about Synths down the road, but for now it's important to know that Synths are inidividual entities that exist on the audio server, and that they can be destroyed using the message "free". Using this method, we can selectively remove sounds instead of terminating all sounds via command-period. For example, if we store our Synth in a global variable, we can free it, like so, which is slightly more elegant than command-period:

x = {SinOsc.ar}.play;

x.free;

Here's a common mistake that I see from time to time. I'll first create and name a Unit Generator function, like this

x = {SinOsc.ar};

play it,

x.play;

and then try to free it.

x.free;

But this doesn't work, so I need to hit command-period instead. The reason it doesn't work is that in the first statement, we store a Function in the variable x. We then play the function, but we don't store the resulting Synth in its own variable, so the Synth is inaccessible. When we evaluate x.free, SuperCollider tries to free the Function stored in x. But of course it's the Synth, the process that's actually running on the audio server, that needs to be freed. Therefore, the correct way to do this is to store x.play in its own variable, like so:

y = x.play;

and then we can free the Synth, which has been stored in the global variable y:

y.free;

Let's spend some time talking about Unit Generators, which are more often referred to as UGens. Let's start by looking at the help file for UGen. Remember that you can bring up a search bar by hitting shift-command-d. The description is fairly straightforward. "UGens represent calculations with signals. They are the basic building blocks of synth definitions on the server, and are used to generate or process both audio and control signals." Just below, we can see that UGens accept three messages: ar, kr, and ir, which stand for audio rate, control rate, and initialization rate. Audio rate UGens output values at the sample rate, and in this case that means 44100 samples per second. If you want to hear the output of a UGen, or if you want a high-resolution waveform, you should use .ar. In the previous example, I've used .ar for SinOsc because I want to hear the resulting sine wave that SinOsc produces.

By default, UGens running at the control rate output one value for every 64 audio samples, which means they run 64 times slower than audio rate UGens, and therefore use less of your computer's CPU. The .kr method should be used for UGens that shape or control other UGens, for example, if you're controlling the amplitude or frequency of an audio rate oscillator. Ir UGens don't continuously output values, instead they calculate only one value when the Synth is first instantiated, and it's arguably the rarest of these three methods.

The top of the UGen helpfile has references to three other help documents: Browse UGens, Tour of UGens, and Unit Generators and Synths, and these are all worth reading if you'd like to learn more. But for now, let's dig a little deeper into UGens. We'll begin by looking at the help file for SinOsc. Remember that you can place the cursor on any text and press command-D to bring up its helpfile, if it exists.

As indicated immediately below the class name, SinOsc is an interpolating sine wavetable oscillator. In UGen help files, there's usually a brief description...the available methods...the arguments that the UGen expects...and some examples, which can be evaluated just like you would with ordinary code in the text editor.

ahh, I love that sound.

Let's talk about Arguments. As we can see in the help file, SinOsc needs four values to produce a signal: freq... phase... mul... and add. Respectively, these arguments represent the frequency of the oscillator (which of course determines the pitch of the tone produced), an inital phase offset into the wavetable in radians, a value to multiply by each sample, and a value to add to each sample. Mul translates to amplitude scaling and add translates to DC offset. Mul and add are in fact quite ubiquitous. Nearly every UGen's last two arguments are mul and add.

If we don't specify values for these arguments, as has been the case so far, then the default values are used. We can see from the help file that the default values, in order, are 440Hz, 0 radians, amplitude scaling of 1, and DC offset of 0.

We can specify our own values for these arguments by creating a parenthetical enclosure after the rate method. Notice the convenient pop-up text that tells you the names of the arguments and their default values, so you don't have to look up the help file every time. Here' I'll set the frequency to 700Hz and the amplitude to one-eighth full volume.

{SinOsc.ar(700, 0, 0.125, 0)}.play

If we specify values for less than all of the arguments, then the defaults are used for the rest. Here you can hear that the amplitude has returned to its default value of 1.

{SinOsc.ar(700)}.play

We can also skip arguments, or specify them in a custom order, by providing the name of the argument you want to specify, a colon, and the value. Here the first value is still interpreted as frequency, but I'm telling the interpreter that I want to skip phase and go straight to mul:

{SinOsc.ar(700, mul:0.125)}.play

UGens can perform mathematical computations like addition, subtraction, exponentiation, etc, so as an alternative for mul and add, you can simply multiply or add a constant value:

{SinOsc.ar(700) * 0.125}.play

I won't mess around with adding values, because DC offset on an audible signal isn't very healthy for speakers.

...

When you create and play a function, you have the option to declare your own arguments, so that you can manipulate the sound as it's playing. Arguments are declared with an arg statement, just like a variable declaration from the previous tutorial. If you're using arguments and variables, then arguments must be declared first, then variables, then the rest of your code.

(
z = {
	arg freq=440, amp=1;
	var sig;
	sig = SinOsc.ar(freq) * amp;
}.play
)

Just like the "free" message, you can use the "set" message to modify arguments of an active Synth. Just specify the argument as a symbol by preceding it with a backslash, a comma, and the value for that argument. We can change the frequency...We can change the amplitude... and we can change both together in one statement. And the order of the arguments in a set command doesn't have to match the order in which they were declared.

z.set(\freq, 330)
z.set(\amp, 0.125)
z.set(\freq, 660, \amp, 1)
z.set(\amp, 0.125, \freq, 550)
z.free;

Also, keep in mind that you can name your arguments and variables whatever you like, as long as they start with lowercase alphabetic characters. I've used freq, amp, and sig because they're short and meaningful, but you can call them whatever makes the most sense to you.

The real fun comes from using UGens to control other UGens. For example, we can make a slightly more complex UGen function in which the frequency of a sine oscillator is controlled by a non-interpolating noise generator LFNoise0...Since we're using a noise generator instead of a constant numeric value, we'll use a variable for frequency instead of an argument...since LFNoise0 is controlling another UGen, we should use .kr. The first argument is the frequency with which the noise generator will out a new random value, let's say 8 random values per second. The default output of LFNoise0, like SinOsc, ranges between -1 and 1. I'll set mul equal to 400 and add to 600, so that the actual output of LFNoise0 is between 200 and 1000 Hz. Then, all we have to do is use our noise generator, which we've named "freq", as a frequency input to our sound source.

(
z = {
	var freq, sig;
	freq = LFNoise0.kr(8, 400, 600);
	sig = SinOsc.ar(freq);
}.play;
)

z.free;

A more intuitive way of specifying the output range of a UGen is to use the "range" message, like so:

(
z = {
	var freq, sig;
	freq = LFNoise0.kr(8).range(200,1000);
	sig = SinOsc.ar(freq);
}.play;
)

z.free;

But be sure you don't specify mul/add while Simultaneously using a range method, because they will conflict with one another.

Since humans perceive frequency exponentially, it's usually more desirable to specify an exponential distribution for a range of frequency values, using the 'exprange' message. This will sound like a more equal distribution of frequency values, whereas the previous example tends more toward the higher end of the range:

(
z = {
	var freq, sig;
	freq = LFNoise0.kr(8).exprange(200,1000);
	sig = SinOsc.ar(freq);
}.play;
)

z.free;

All UGens understand range and exprange, and there are other useful methods that you can read about in the UGen help file.

Let's control the amplitude as well, in this case with a linearly interpolating noise generator, LFNoise1:

(
z = {
	var freq, amp, sig;
	freq = LFNoise0.kr(8).exprange(200,1000);
	amp = LFNoise1.kr(12).exprange(0.02,1);
	sig = SinOsc.ar(freq) * amp;
}.play
)

z.free;

And just for fun, let's add an argument to this UGen function, which we'll use to control the frequency of LFNoise0

(
z = {
	arg noiseHz=8;
	var freq, amp, sig;
	freq = LFNoise0.kr(noiseHz).exprange(200,1000);
	amp = LFNoise1.kr(12).exprange(0.02,1);
	sig = SinOsc.ar(freq) * amp;
}.play
)

Now we can change the frequency of LFNoise0 on-the-fly

z.set(\noiseHz, 16);

For even more fun, we can have SuperCollider generate a random value each time we evaluate this statement:

z.set(\noiseHz, exprand(4,64));
z.free;

That's all for this tutorial. I hope this is enough to help you get off the ground with some sound experimentation. In the next video, We'll talk in more depth about Synth, and it's parter in crime, SynthDef. Please leave any comments or questions on YouTube. Thanks for watching.