# Riverpod Example

This example shows how to use Riverpod with Jaspr. 

## Overview

The project uses the `jaspr_riverpod` package and displays a basic counter component.

It leverages jasprs server-side rendering capabilities to get the initial count on the server and
prerender the app with that count. The client will then start on the value set by the server.

The actual value is taken from the 'count' query parameter. So e.g. opening `localhost:8080/?count=10` 
will start at count of 10.

