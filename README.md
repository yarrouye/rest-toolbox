REST Toolbox
============

A small collection of commands making life easier when interacting with REST services.

Easy Interaction With HTTP Servers and Services
-----------------------------------------------

curl(1) is not very easy to use and its command line, while very powerful,
is quite verbose. easy(1) makes it trivial to invoke HTTP servers and
services. It is great tool to play with REST services. Examples in this
document put the emphasis on those HTTP methods that are used with such
services.

*Simple Invocation*

One can make a call to a service using a simple invokation such as:

    $ easy POST http://127.0.0.1/service/v1/resources

This is equivalent to:

    $ easy --endpoint http://127.0.0.1/service/v1 POST /resources

While that is not that much great news in itself, easy(1) can also use the
contents of `$EASYENDPOINT` as the endpoint. So one could issue a few
commands to the same endpoint by doing something like:

    $ export EASYENDPOINT=http://127.0.0.1/service/v1
    $ easy POST /resources
    ...
    $ easy GET /resources/23
    ...
    $

Okay, that might be better if you want to issue a lot of commands for a
given host. If you want even simpler, you can ask easy(1) to generate some
functions for you. See Shortcut Trickery below.

*Easy Baking and Cooking*

Passing the `-j` or `--json` option to easy(1) causes it to
automatically insert the proper headers for interaction using JSON as the
content type.

In addition, if easy(1) is passed the `-B` or `--baked` argument it will
take a number of command line arguments formatted as assignments and bake
them into the proper data format to send them.

    $ easy -B POST /persons name=Yves zipcode:=98004 company='Expedia, Inc.'

will bake the data string `name=Yves&zipcode=98008&company=Expedia%2C%20Inc.`
for submission, while

    $ easy -jB POST /persons name=Yves zipcode:=98004 company='Expedia, Inc.'

will bake the following JSON object (prettifying notwithstanding):

    {
        "name": "Yves",
        "zipcode": 98004,
        "company": "Expedia, Inc."
    }

The `:=` assignment tells easy(1) to use the value literally rather than
to quote it as a string.

One can also use arguments when using `GET`. The arguments will then be passed
in the query portion of the request, unles `-q` or `--query` was used, in
which case they will be sent as part of the body (which may not be supported
by the destination):

    $ easy -B GET /persons count=5

would fetch `/persons?count=5` and return the results. Note that `:=` tells
easy(1) to not URL-encoded the values, which is its default behavior (just
like it string quotes values in JSON).

The special form `:` means to pass the data without a value. Doing

    $ easy -B GET /persons start=3 count

will result in fetching `/persons?start=3&count` while doing

    $ easy -jB POST /persons name=Yves zipcode:=98004 age:

would bake and send

    {
        "name": "Yves",
        "zipcode": 98004,
        "age": undefined
    }


To prevent baking, one can use `-W` or `--wet`.

While by default easy(1) does very little to change one's typical exchange
with an HTTP server, it can cook the server's responses if passed the
`-C` or `-c` option.

Cooking the response has a big impact on what one sees. The response is
cooked by easy(1) according to the following recipe:

- Prettify (formats and colorizes if possible) the HTTP response headers
- Produce a blank line
- Prettify the response's contents

easy(1) calls pretty(1) for prettification. See Prettify Content below.

The `-C` or `--cooked` option always cooks the results. It will not produce
colors if writing to a terminal unless the option is used twice. Doing so
is useful if one wants to page with `less -R` for example. The `-c`
option tentatively cooks results, i.e. only cooks them if writing to a
terminal.

Cooked mode makes for a very pretty interaction. For quick testing of REST
services, `-jc` is a must, and adding baking is probably as indispensable
too. Or simply invoke easy(1) as rest(1) as described below!

One can request no cooking by using the `-R` or `--raw` option.

*Posting, Putting, Patching: When Data Are Needed*

Make a POST without sending data, which is often used to create a new
resource in REST services:

    $ easy POST /resources

Make a POST and specify the data on the command line:

    $ easy -jB POST /resources '{ "key": "value" }'

Make POST and create the data using your favorite editor. The editor will
be taken from `$VISUAL`, `$EDITOR`, vim(1) and vi(1) in this order. If
easy(1) cannot find a program apecified by an environment variable, it does
ignore it.

    $ easy -jV POST /resources

Pipe data between services and edit them before they are posted (the `-VV`
flag tells easy(1) to edit the data that were provided):

    $ easy --endpoint http://localhost/ GET /things/1 | easy -jVV POST /resources

Update a resource with PUT:

    $ easy PUT -jB /resources/1234 '{ "key": "something" }'

You get the idea...

*Putting, Patching Etc. Through a Picky Gateway or Firewall*

Simply ask easy(1) to override POST:

    $ easy -O PUT /resources/1234 'key=something'

*Easy as REST?*

When invoked as `rest`, easy(1) behaves as if the `-jBc` options has been
passed to it. 
This provides a great experience for interacting with
JSON-based REST services. The rest(1) command provides other options to
negate those defaults (e.g. `-f` to use form data instead of JSON).

*Shortcut Trickery*

As indicated above, easy(1) (or rest(1) of course) can generate functions
for you to allow for very simple invocations:

    $ easy --print all
    export EASYENDPOINT=http://127.0.0.1/service/v1;
    DELETE () {
        easy DELETE "$@"
    };
    HEAD () {
        easy HEAD "$@"
    };
    GET () {
        easy GET "$@"
    };
    OPTIONS () {
        easy OPTIONS "$@"
    };
    POST () {
        easy POST "$@"
    };
    TRACE () {
        easy TRACE "$@"
    };
    $

In order to have these functions available to you, simply evaluate the
output of `easy --print` or `easy -P`:

    $ eval `easy --print all`
    $ env | grep EASYENDPOINT
    EASYENDPOINT=http://127.0.0.1/service/v1
    $ functions
    DELETE () {
        easy DELETE "$@"
    }
    HEAD () {
        easy HEAD "$@"
    }
    GET () {
        easy GET "$@"
    }
    OPTIONS () {
        easy OPTIONS "$@"
    }
    POST () {
        easy POST "$@"
    }
    TRACE () {
        easy TRACE "$@"
    }
    $

Now you can just call `DELETE`, `GET` etc. If you want to use a different
endpoint, simply reset the value of `$EASYENDPOINT` or temporarily override
it by passing an endpoint with the `--endpoint` option.

If you use csh(1) or tcsh(1), you can get definitions that your shell will
understand too. Note that easy(1) relies on the value of `$SHELL` to determine
what to do, so if you call a new shell from an existing shell you may have
to set that variable properly yourself.

    csh% easy --print all
    setenv EASYENDPOINT http://127.0.0.1/service/v1;
    alias DELETE 'easy DELETE \!* ';
    alias HEAD 'easy HEAD \!* ';
    alias GET 'easy GET \!* ';
    alias OPTIONS 'easy OPTIONS \!* ';
    alias POST 'easy POST \!* ';
    alias TRACE 'easy TRACE \!* ';
    csh%

You can add arguments too, and they will be remembered.
You can also specify a method name and only that method will have
a function or an alias defined for it. This allows for example to have
different arguments for different methods:

    $ easy --print func GET -H 'Client-Id: 128efe71k19'
    GET () {
        easy GET "$@" -H 'Client-Id: 128efe71k19'
    };
    $ easy --print func POST -H 'Client-Id: 128efe71k19' -H 'Content-Type: application/json'
    POST () {
        easy POST "$@" -H 'Client-Id: 128efe71k19' -H 'Content-Type: application/json'
    };
    $ 


Determine the MIME Type of a File
---------------------------------

mime(1) determines the MIME type of a file and is able to print the common file
extensions associated to that MIME type. It can also be used to test whether some
content is of a given MIME type.


Prettify Content
----------------

pretty(1) formats (pretty prints) and colorizes content. The pretty.commands(5)
file maps MIME types to formatting and colorization commands appropriate for
a variety of MIME types. If a command in the file is not found, pretty(1)
will use cat(1) instead ("So much for prettification!" you say; but at least
contents will not seemingly disappear).

In order for prettification to happen, easy(1) needs to be able to find
pygmentize(1) (from the pygments project at http://pygments.org) and json(1)
(from https://github.com/trentm/json).


Open Standard Input in the Right Application
--------------------------------------------

openstdin(1) is a simple script that allows one to open standard input in an
appropriate application as determined by open(1).

It can automatically determine the proper file extension to use
for open to pick an application. In order to do so it relies on file(1)
and a mime.types file (either Apache's or CUPS's mime.types(5) can
be used).

