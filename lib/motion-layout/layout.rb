module Motion
  class Layout

    OPTIONS_SYMBOLS = {
      left: NSLayoutFormatAlignAllLeft,
      right: NSLayoutFormatAlignAllRight,
      top: NSLayoutFormatAlignAllTop,
      bottom: NSLayoutFormatAlignAllBottom,
      leading: NSLayoutFormatAlignAllLeading,
      trailing: NSLayoutFormatAlignAllTrailing,
      centerx: NSLayoutFormatAlignAllCenterX,
      centery: NSLayoutFormatAlignAllCenterY,
      baseline: NSLayoutFormatAlignAllBaseline,
    }

    def initialize(&block)
      @verticals   = []
      @horizontals = []
      @metrics     = {}

      yield self
      strain
    end

    def metrics(metrics)
      @metrics = Hash[metrics.keys.map(&:to_s).zip(metrics.values)]
    end

    def subviews(subviews)
      @subviews = Hash[subviews.keys.map(&:to_s).zip(subviews.values)]
    end

    def view(view)
      @view = view
    end

    def horizontal(horizontal, *options)
      kw = extract_keywords!(options)
      @horizontals << [horizontal, resolve_options(options), kw]
    end

    def vertical(vertical, *options)
      kw = extract_keywords!(options)
      @verticals << [vertical, resolve_options(options), kw]
    end

  private

    def extract_keywords!(options)
      if options.last.kind_of?(Hash)
        options.pop
      else
        {}
      end
    end

    def resolve_options(opt)
      opt.inject(0) do |m,x|
        if x.kind_of?(Numeric)
          m | x.to_i
        elsif o = OPTIONS_SYMBOLS[x.to_s.downcase.to_sym]
          m | o
        else
          raise "invalid opt: #{x.to_s.downcase}"
        end
  	  end
    end

    def apply_keywords(kw, constraints)
      priority = kw[:priority]
      unless priority.nil?
        constraints.each{|c| c.priority = priority}
      end
      constraints
    end

    def strain
      @subviews.values.each do |subview|
        next if subview == @view
        subview.translatesAutoresizingMaskIntoConstraints = false
        @view.addSubview(subview) unless subview.superview
      end

      constraints = []
      constraints += @verticals.map do |vertical, options, kw|
        c = NSLayoutConstraint.constraintsWithVisualFormat("V:#{vertical}", options:options, metrics:@metrics, views:@subviews)
        apply_keywords(kw, c)
      end
      constraints += @horizontals.map do |horizontal, options, kw|
        c = NSLayoutConstraint.constraintsWithVisualFormat("H:#{horizontal}", options:options, metrics:@metrics, views:@subviews)
        apply_keywords(kw, c)
      end

      @view.addConstraints(constraints.flatten)
    end
  end
end
