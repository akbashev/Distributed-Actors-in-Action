# Distributed Actors in Action

## TODO:
* Erlang -> Akka
* Evolution of Akka
* Swift Actor proposal
* Something else?

## Motivation

👋 Hello, my dear Swift developer. You're probably wondering why I've started porting examples of Scala's Akka framework to Swift. Let me explain. 🧙‍♂️

When Apple announced Actors for Swift, along with the new concurrency tools, it was something new which I had only briefly heard about. It was being sold as a way to prevent data racing in code—encapsulate state and use actors for it. Magic! 🦄 And while this statement was and still is true, there was another thing happening in the background meanwhile, called [Distributed actors](https://www.swift.org/blog/distributed-actors/). It hooked me. This was not something for iOS or macOS specifically, but more for server-side Swift, which I've used and loved before with the [Vapor](https://vapor.codes) framework in production.

I jumped into the topic a bit later in 2022 and immediately faced an issue—it's hard to reason about and design a distributed app when you've never worked on it. And as Swift before has mostly focused on Apple platforms, I think I'm not alone here.

The Actor model is not something new in the industry, actually as old as the object-oriented paradigm, and there should be some resources to learn which could be applied to Swift implementation. So I grabbed several books and started researching. One of the books I purchased and which I've lately started to read is [Akka in Action](https://www.manning.com/books/akka-in-action). While reading it, I got an idea that others shouldn't suffer like me 🥲, and it would be nice for others to have a good overview of the Actor model, compare it with industry standards, and then easily implement and create wonderful distributed apps with Swift.

So here we are. If you're a Swift developer, I hope this repository will help you on your path to understanding new concurrency tools. Feel free to contribute and improve anything here! 😉

But first, let's briefly understand why the Actor model is even needed.

### Actor Model

The Actor Model is a computational model that was created in the 1970s by Carl Hewitt, Peter Bishop, and Richard Steiger. There is a [nice video](https://www.youtube.com/watch?v=7erJ1DV_Tlo) where Hewitt explains the Actor model to Meijer and Szyperski. It's nothing hard actually and interesting. I highly recommend watching it. But it's important to understand why it was created in the first place.

If we're talking about computation (in the end we're using computers 👀 exactly for this reason), there are two models that first come to mind—the Turing machine and Lambda calculus. Most modern languages and programs are actually built on principles of these two models. The problem is they are based on a sequential, single-threaded model of execution that is not suitable for concurrent processing. People have been researching ways for concurrent computation.

The Actor Model was created as an alternative to the Turing machine and lambda calculus models, based on a message-passing paradigm, where computation is performed by a collection of independent entities called "actors". These actors communicate with each other by exchanging messages, allowing them to operate concurrently without interfering with each other.

### Influences

But why being created in 1970s it was not wide spread afterwards?

For quite some time afterwards there was just no need for distrubuted computation. Only by the end of 80s Telekom providers, which by the nature were distributed, started to investigate on languages that can be used for them.

At the time, Ericsson was developing a new generation of telecommunications switches that needed to be highly reliable and able to handle large amounts of traffic. Armstrong and his colleagues realized that existing programming languages were not well-suited to the task of building such a system. They needed a language that could handle concurrency, fault tolerance, and distributed computing, among other requirements. To address these challenges, Armstrong developed Erlang as a new programming language.

Erlang's design was heavily influenced by Armstrong's experience working with Prolog and Lisp, as well as his interest in the actor model of computation, although he was not aware of it at the begginig, so basically they've reinvented it. The language quickly gained popularity within Ericsson and later in the wider programming community, particularly for its ability to handle large-scale telecommunications systems with high reliability and fault tolerance.

Still though Erlang stayed mostly niche language for Ericsson throughout 90s.

### Internet

I guess everyone understood by now why people started to look at Erlang and Actor model again in 00s—Internet happened. As more and more applications moved to the cloud and required distributed systems, developers began to look for programming models that could handle the challenges of concurrency and distributed computing. The Actor model made it a good fit for these kinds of systems.

On top with the rise of multi-core processors, parallel computing became more important. Again, developer noticed, that Erlang works flawleslly on those processors and there is no need to change code dramatically.

TBD.
