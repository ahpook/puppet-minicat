require 'puppet'
require 'puppet/face'
require 'awesome_print'

Puppet::Face.define(:minicat, '0.0.1') do

  copyright "Apple Inc", 2012
  license   "Apple Internal Use"

  summary "Make a mini-catalog, to view data-driven template output"
  description <<-EOT
    This subcommand eases the debugging of external-data-driven Puppet templates by fetching the External Node 
    Classifier output from the exec terminus but modifying the list of classes to a user-specified subset.
  EOT

  action 'compile' do
    summary "Compile and display a catalog locally, driven by the node classifier"
    description <<-EOT
      Similar to puppet apply, but with the option to (a) pretend to be a different node and
      (b) modify the list of classes returned by the node classifier
    EOT
    
    option "--node NODENAME" do
      summary "Fetch data from the ENC as if we were this node"
      required
    end
    option "--classlist puppet::class1,puppet::class2" do
      summary "Comma-separated list of classes to include in the compiled catalog (defaults to ENC list if omitted)"
    end

    when_invoked do |options|
      Puppet[:config] = options[:config] || '/etc/puppet/puppet.conf'
      Puppet.parse_config
      node = Puppet::Node.indirection.find(options[:node])
      if options[:classlist]
        node.classes = options[:classlist].split(',')
      end

      catalog = Puppet::Resource::Catalog.indirection.find(node.name, :use_node => node)

      print catalog.to_pson

    end

  end

end
