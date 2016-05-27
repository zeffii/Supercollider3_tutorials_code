Hey everyone, welcome to tutorial number 6. In this video I'll talk about iteration and how it can be used for audio synthesis. Iteration is a topic in and of itself, but essentially, iteration is a repeating process. It enables the user to execute a block of code many times over, usually until some condition is met or a certain number of iterations have been performed.

It's very common to iterate over a collection of items. And by this I mean you take a collection, and one-by-one, pass the individual items into a function as input arguments. In the class library there's an object called Collection, which is the parent of many useful subclasses, listed here at the top. There's also a file called Collections, that outlines the subclass hierarchy. One of these subclasses is Array, which we're already sort of familiar with.

Back in the Collection help file, we can do a search for the word "iteration", which takes us to a list of relevant methods. There are quite a few, but the most generalized method is called "do", which simply evaluates a function for each item in the collection.

To iterate over a collection, we first need to create a collection. So here's an array of several numbers

[6, 4, 0.5, 10, 7]

and to iterate over this array, we'll send it the message "do", and provide a function. I'll keep things fairly simple, and just print "hello" for each iteration.

[6, 4, 0.5, 10, 7].do{"hello".postln};

Because there are five items in the array, we see the word 'hello,' 5 times. We also see the original array in the post window, and this is because do always returns its receiver. This is usually irrelevant, and it's probably best to ignore this or just think of it as a side effect of using do.

More importantly, you might have noticed that the same result would have been produced from an array of ANY five items, so this is not a particularly instructive example.

In many cases, you'll want to incorporate somehow the collection's items into the function. For example, if you have a list of 200 file names, you might want to change the extension on all of these files names, and this is where the real strength of iteration comes into play. To pass items into a function, we declare an input argument, whose value will range over the contents of the collection. In this particular function, we're going to square each item and post the result.

(
[6, 4, 0.5, 10, 7].do{
	arg item;
	item.squared.postln;
}
)

In some cases, you might also want to keep track of how many times the function has been evaluated, or in other words, how many iterations have occured. This is done by adding a second argument to the function, like this. Now, on each iteration, I'll instead post an array containing the current number of iterations, and the current item, squared.

(
[6, 4, 0.5, 10, 7].do{
	arg item, count;
	[count, item.squared].postln;
}
)

You might notice that we're not actually storing the results of this data manipulation anywhere, we're just posting information. Using do, if you'd actually like to return and store a modified collection, you'd have to change this array manually within the function. First, it's probably a good idea to create a new empty array to hold our resulting calculations, since it's generally risky and perhaps undesirable to overwrite data. The function squares every item in the array and stores each result at the corresponding index in the array x.

(
x = Array.newClear(5);

[6, 4, 0.5, 10, 7].do{
	arg item, count;
	x[count] = item.squared;
};
)

The last evaluated statement in this clump of code is a do statement, which, as we've seen, returns its receiver, but sure enough, if we query the global variable x, we can see it is the collection of our new data.

x;

But 'do' isn't the best method to use for something like this. It's much easier to use a method called collect, which returns a new collection instead of just returning its receiver. While we've explicitly stored new data in the function above, collect does this automatically. So all we'd have to type is this;

(
z = [6, 4, 0.5, 10, 7].collect{
	arg item;
	item.squared;
};
)

And for anyone who has a sweet tooth for syntactic sugar, you can even use this condensed underscore notation.

z = [6, 4, 0.5, 10, 7].collect(_.squared);

One more thing before we move on to audio, I'll point out that positive integers respond to "do" by iterating from 0 up to and not including their value. So something like

5.do;

is effectively the same as the array 0 through 4 .do

[0,1,2,3,4].do

and just to prove this, I'll iterate over the array, and post each item,

[0,1,2,3,4].do{arg item; item.postln};

and then execute 5.do and post each item:

5.do{arg item; item.postln};

We're using different receivers, but the results of these two functions are indistinguishable.

s.boot;

So now, let's move on to iterative synthesis in order to see how we can use "do" with UGens. Take, for instance, this simple variable duty sawtooth wave.

x = {VarSaw.ar(40!2, 0, 0.05)}.play;
x.free;

It's nice, but, uh, you know, it's not particularly interesting or anything. But with iteration, we can layer many of these sounds together to create something much richer. In the following SynthDef I'll declare two variables, temp and sum. Temp will be used within the iteration block to hold a temporary signal, and sum will be the eventual output signal. So to start, I'll initialize sum to zero. Within the iteration block, which will be evaluated 10 times, I'll create an audio rate VarSaw, but I'll randomize the frequency a little bit. The second argument is the phase, and the third argument is the duty cycle. Then, I'll add this signal to the output signal and store the result. So what'll happen here is that this function will be evaluated ten times, and on each iteration, we create a stereo VarSaw whose frequency is slightly and uniquely offset from 40Hz, and then add this signal to a running total. By the end, we've accumulated 10 unique sawtooth waves, summed together. Because of this, it's a good idea to scale down this signal since it's probably going to clip. And last but not least, we need an output UGen.

(
SynthDef.new(\iter, {
	var temp, sum;
	sum = 0;
	10.do{
		temp = VarSaw.ar(
			40 * {Rand(0.99,1.02)}!2,
			0,
			0.05
		);
		sum = sum + temp;
	};
	sum = sum * 0.05;
	Out.ar(0, sum);
}).add;
)

Before we dive into this example, I just want to point out what happens if we don't initialize sum. Without a starting value, sum is equal to 'nil' which is a special value given to variables that don't have a value. SuperCollider doesn't know how to add things to nil (and quite frankly it doesn't make sense to me either), so it runs into trouble on this line. Sure enough, SuperCollider tells us that it couldn't make heads or tails of the plus operator. So that's why we need to initialze our output signal.

x = Synth.new(\iter);
x.free;

Right off the bat, this sounds a lot more interesting than the single VarSaw. But as you might have heard, there's a huge pop at the beginning of this sound. And it's pretty ugly. and that's because these VarSaws all have the same initial phase offset, zero. So if we randomize the phase as well, we can smooth out the sound a bit.

(
SynthDef.new(\iter, {
	var temp, sum;
	sum = 0;
	10.do{
		temp = VarSaw.ar(40 * {Rand(0.99,1.02)}!2, {Rand(0.0,1.0)}!2, 0.05);
		sum = sum + temp;
	};
	sum = sum * 0.05;
	Out.ar(0, sum);
}).add;
)

x = Synth.new(\iter);
x.free;

And, you know, while we're at it, we could randomize the duty cycle as well.

(
SynthDef.new(\iter, {
	var temp, sum;
	sum = 0;
	10.do{
		temp = VarSaw.ar(40 * {Rand(0.99,1.02)}!2, {Rand(0.0,1.0)}!2, {ExpRand(0.005, 0.05)}!2);
		sum = sum + temp;
	};
	sum = sum * 0.05;
	Out.ar(0, sum);
}).add;
)

x = Synth.new(\iter);
x.free;

I'm gonna throw a doneAction:2 on this SynthDef so I don't have to worry about freeing these Synths anymore.

(
SynthDef.new(\iter, {
	var temp, sum, env;
	env = EnvGen.kr(
		Env.perc(0.01, 5, 1, -2),
		doneAction:2
	);
	sum = 0;
	10.do{
		temp = VarSaw.ar(40 * {Rand(0.99,1.02)}!2, {Rand(0.0,1.0)}!2, {ExpRand(0.005, 0.05)}!2);
		sum = sum + temp;
	};
	sum = sum * 0.05 * env;
	Out.ar(0, sum);
}).add;
)

Synth.new(\iter);


Here's a frequency argument, so that now, we can specify any frequency we like when we instantiate or set the Synth.

(
SynthDef.new(\iter, {
	arg freq=40;
	var temp, sum, env;
	env = EnvGen.kr(
		Env.perc(0.01, 5, 1, -2),
		doneAction:2
	);
	sum = 0;
	10.do{
		temp = VarSaw.ar(freq * {Rand(0.99,1.02)}!2, {Rand(0.0,1.0)}!2, {ExpRand(0.005, 0.05)}!2);
		sum = sum + temp;
	};
	sum = sum * 0.05 * env;
	Out.ar(0, sum);
}).add;
)

Synth.new(\iter, [\freq, 400]);
Synth.new(\iter, [\freq, 300]);
Synth.new(\iter, [\freq, 250]);
Synth.new(\iter, [\freq, 224]);

If you prefer, you can deal in midi note numbers, using the method 'midicps'

Synth.new(\iter, [\freq, 66.midicps]);
Synth.new(\iter, [\freq, 73.midicps]);
Synth.new(\iter, [\freq, 80.midicps]);
Synth.new(\iter, [\freq, 75.midicps]);

And hey, get this. We can even use iteration again to generate multiple synths at the same time:

(
[53,59,63,68].do{
	arg midinote;
	Synth.new(\iter, [\freq, midinote.midicps]);
};
)

Although, to be honest, I would generally not recommend using language-side looping and iteration to create simultaneous Synths, since you run the risk of losing sample-accuracy if you're using a lot of complicated or heavy-duty UGens. But as you heard, even if these four synths aren't technically simultaneous down to the sample-level, it still sounds pretty damn close.

Here, is another example. Unlike the previous SynthDef, this time I'll actually incorporate the iteration count into the audio manipulation. So I'll define an argument within the iteration block, call it 'count'. Notice that I don't actually need a second argument for the iteration count, because when using integer dot do, the items in the collection and the iteration count are actually the same stream of numbers, so using two arguments is redundant. I'll create an overtone of a fundamental pitch by multiplying the frequency by the iteration count. I have to add one because the iteration count starts at zero, and we don't want an oscillator with a frequency of 0Hz. The rest of this example is no different from the previous example.

(
SynthDef.new(\iter2, {
	arg freq=200;
	var temp, sum;
	sum = 0;
	10.do{
		arg count;
		temp = SinOsc.ar(freq * (count + 1));
		sum = sum + temp;
	};
	sum = sum * 0.05;
	Out.ar(0, sum);
}).add;
)

x = Synth(\iter2);
x.free;

What we hear is a stack of 10 partials with a fundamental of 200Hz. Now, granted, there's already a UGen that does this, called blip.

x = {Blip.ar(200, 10, 0.5)}.play
x.free;

But with iteration, we have a lot more control over the individual partials than we do with blip. For instance, we can have the frequency of each overtone meander very slightly using LFNoise1. I'll also invoke multichannel expansion on LFNoise so that we have two unique channels of audio.

(
SynthDef.new(\iter2, {
	arg freq=200;
	var temp, sum;
	sum = 0;
	10.do{
		arg count;
		temp = SinOsc.ar(freq * (count + 1) * LFNoise1.kr({Rand(0.05,0.2)}!2).range(0.98,1.02));
		sum = sum + temp;
	};
	sum = sum * 0.05;
	Out.ar(0, sum);
}).add;
)

x = Synth(\iter2);
x.free;

We can add another statement within the iteration block to have the amplitude of each partial fluctuate randomly.

(
SynthDef.new(\iter2, {
	arg freq=200;
	var temp, sum;
	sum = 0;
	10.do{
		arg count;
		temp = SinOsc.ar(freq * (count + 1) * LFNoise1.kr({Rand(0.05,0.2)}!2).range(0.98,1.02));
		temp = temp * LFNoise1.kr({Rand(0.5,8)}!2).exprange(0.01, 1);
		sum = sum + temp;
	};
	sum = sum * 0.05;
	Out.ar(0, sum);
}).add;
)

x = Synth(\iter2);

and don't forget that we can change the frequency since we have declared an argument for it:

x.set(\freq, 50);
x.free;

Maybe you'd want to control the amount of frequency deviation in addition to frequency. We can declare an argument, and then set the range of LFNoise1 like this.

(
SynthDef.new(\iter2, {
	arg freq=200, dev=1.02;
	var temp, sum;
	sum = 0;
	10.do{
		arg count;
		temp = SinOsc.ar(
			freq *
			(count + 1) *
			LFNoise1.kr({Rand(0.05,0.2)}!2).range(dev.reciprocal, dev)
		);
		temp = temp * LFNoise1.kr({Rand(0.5,8)}!2).exprange(0.01, 1);
		sum = sum + temp;
	};
	sum = sum * 0.05;
	Out.ar(0, sum);
}).add;
)

x = Synth(\iter2);

x.set(\dev, 1.05);
x.set(\dev, 1.1);
x.set(\dev, 1.4);

x.free;

Here's a problem you might run into. Let's say we want even more partials. A natural instinct is to replace the integer receiver of 'do' with an argument, so that we could change it just like we'd change the frequency or frequency deviation.

(
SynthDef.new(\iter2, {
	arg freq=200, dev=1.02, num=10;
	var temp, sum;
	sum = 0;
	num.do{
		arg count;
		temp = SinOsc.ar(
			freq *
			(count + 1) *
			LFNoise1.kr({Rand(0.05,0.2)}!2).range(dev.reciprocal, dev)
		);
		temp = temp * LFNoise1.kr({Rand(0.5,8)}!2).exprange(0.01, 1);
		sum = sum + temp;
	};
	sum = sum * 0.05;
	Out.ar(0, sum);
}).add;
)

x = Synth(\iter2, [\num, 10]);
x.free;

But this doesn't work, as you can hear from this strange result, and I'll tell you why. The reason is that the receiver of 'do' is no longer an integer. It sure looks like an integer, but it's not. It's actually an instance of a class called Control, which is a type of UGen that SuperCollider creates automatically whenever you declare an argument in a SynthDef. The key fact is that Control is not a collection, it's just one thing. So when we iterate over a Control, the Control just passes itself into the function, once... In this case the actual output value of the signal is the default value 10. So 10, plus one, is multiplied by the fundamental frequency, 200Hz, and then there's some slight frequency deviation. What we end up hearing is basically just a 2.2kHz tone, which, coincidentally, is not my favorite sound.

Just to prove this, I'll start up the sound again, and I'll set the argument 'num' equal to some different floating point values just to show that it serves no other purpose than as a frequency multiplier.

x = Synth(\iter2, [\num, 10]);
x.set(\num, 8.7);
x.set(\num, 5.4);
x.free;

So in that example, there's really no iteration happening at all. Changing the number of iterations in a SynthDef in real-time essentially boils down changing the code in a SynthDef in real-time, which, from what I understand about how SuperCollider is designed, is pretty much impossible. So, the best way to change the number of partials is to just manually change the iteration receiver and then re-evaluate the SynthDef.

(
SynthDef.new(\iter2, {
	arg freq=200, dev=1.02;
	var temp, sum;
	sum = 0;
	20.do{
		arg count;
		temp = SinOsc.ar(
			freq *
			(count + 1) *
			LFNoise1.kr({Rand(0.05,0.2)}!2).range(dev.reciprocal, dev)
		);
		temp = temp * LFNoise1.kr({Rand(0.5,8)}!2).exprange(0.01, 1);
		sum = sum + temp;
	};
	sum = sum * 0.05;
	Out.ar(0, sum);
}).add;
)

x = Synth(\iter2);
x.free;

That's it for tutorial number 6. If you'd like to see more, I've got an older video on this channel that deals with creating an infinite reverb effect, which also includes some SynthDef iteration. But keep in mind these are just a few improvised examples in a sea of possibilities. What you end up putting in an iteration block is limited only by your imagination, so I absolutely encourage you to experiment.

What I'd like to do next is talk about the architecture of the audio server in more detail. So far we've just been dumping Synths onto the server with reckless abandon, but our examples have been simple enough that we can get away with this. But when you develop a more sophisticated and interconnected collection of audio generators and processors, there's a whole family of server-related classes that come into play, such as Nodes, Groups, Busses, and additionally, some important concepts arise, such as inputs & outputs and order-of-execution. The latter is actually described as "one of the most critical and seemingly difficult aspects of using SuperCollider." I might not put it that strongly, but I will say that Server Architecture is probably one of the most extensive and important topics, so I'll probably break it down into at least two videos, possibly three. After a thorough tutorial on Server Architecture, I hope I'll have provided a fairly comprehensive introduction, and from there I only have vague ideas of what to discuss next. I'd definitely like to cover Tasks & Routines, Patterns, and GUI, but I'm also open to suggestions. But anyway, thanks for watching this tutorial, and see you next time.