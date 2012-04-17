## puppet-minicat -- Make a mini-catalog, to view data-driven template output

### Synopsis

This subcommand eases the debugging of external-data-driven Puppet templates by fetching the External Node
Classifier output from the exec terminus but modifying the list of classes to a user-specified subset.

### Rationale

As we move towards better separation between data and code, especially for complex templates, the distance between 
manipulating the data and observing the results of the manipulation can become quite wide. In my environment, we make 
heavy use of external node classifier variables to define template values, which is quite powerful, but imposes 
workflow like:

    modify ENC database values ->
    modify puppet code ->
    check in puppet code ->
    update test puppet master ->
    run client against test master

This can make it slow to iterate quickly when testing new changes.  `puppet-minicat` is meant shorten the cycle, by 
allowing someone working on a template to consult the node classifer as if they were the real end client, generating  
just the subset of the catalog that contains the class they're working on, and printing that catalog out in text format 
instead of trying to actually apply it.

### Usage

To use `puppet-minicat`, simply download the module and adjust your `RUBYLIB` environment variable to include the 
module's `lib/` subdirectory. running `puppet help` should show you the one-line help text for minicat along with
the other faces, and `puppet man minicat` should show the complete help text.

In actual usage, I found it helpful to create a small `puppet.conf` which sets the `modulepath`, `node_terminus` and 
`external_node` config variables. The `external_node` script can simply return the output from the node classifier for 
the node we're interested in, or, if you already have a web-service-accesible node classifier, it can return the actual 
output. In the latter case, the `--node` argument to `puppet minicat` will let you specify the node whose data should 
be requested.

A typical command line looks like this:

    puppet minicat compile --debug --config ./etc/puppet.conf --node puppetmaster.domain.com \
       --classlist puppet::master::environments --modulepath=/Users/eric/Sandbox/puppet-config/trunk/modules 

This fetches the node classifier information for `puppetmaster.domain.com` and uses its `parameters:` section to
compile a catalog containing only those resources in the `puppet::master::environments` class, using my working
copy changes to the puppet modules.  The output is a screenful of json which contains the thing I'm most interested
in debugging: a template-ized puppet.conf which uses node classifier data to set up an `\[environment\]` stanza for
each of the test branches.

### Requirements

Puppet 2.7.x is required to use the Faces API.

### Contact

The code lives at [puppet-minicat](https://github.com/ahpook/puppet-minicat), please feel free to fork and 
file issues or pull requests there.
