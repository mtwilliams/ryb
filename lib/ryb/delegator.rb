module Ryb
  class Delegator
    def initialize(context, opts={})
      @context = context
      # TODO(mtwilliams): Hide standard methods, too.
      @hidden = ((opts[:except] || []).map(&:to_sym))
      @hooks = ((opts.select {|k,_| /^on_.+/.match(k)}).map {|k,v| [k[3..-1].to_sym, v]}).to_h
    end

    def method_missing(name, *args, &block)
      name = name.to_sym
      super if @hidden.include? name
      if @context.respond_to? name
        response = @context.send(name, *args, &block)
        @hooks[name].call(response) if @hooks.include? name
      else
        super
      end
    end
  end
end
