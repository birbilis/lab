###
Simple module which provides mutations context menu for DNA nucleotides.

CSS style definition: sass/lab/_context-menu.sass
###
define (require) ->

  ###
  Registers context menu for DOM elements defined by @selector.
  @model should be an instance of Modeler class (MD2D Modeler).
  @DNAComplement indicates whether this menu is registered for
  DNA or DNA complementary strand.
  ###
  register: (selector, model, DNAComplement) ->

    # Unregister the same menu first.
    $.contextMenu "destroy", selector
    # Register new one.
    $.contextMenu
      # Selector defines DOM elements which can trigger this menu.
      selector: selector
      # Append to "#responsive-content" to enable dynamic font-scaling.
      appendTo: "#responsive-content"
      # Class of the menu.
      className: "mutations-menu"
      # Left click.
      trigger: "left"

      events:
        show: (options) ->
          type = d3.select(options.$trigger[0]).datum().type
          subsItems = options.items["Substitution"].items
          for own key, item of subsItems
            key = key.split(":")[1]
            item.$node.addClass "#{type}-to-#{key}"
          # Ensure that this callback returns true (required to show menu).
          true

        hide: (options) ->
          type = d3.select(options.$trigger[0]).datum().type
          subsItems = options.items["Substitution"].items
          for own key, item of subsItems
            key = key.split(":")[1]
            item.$node.removeClass "#{type}-to-#{key}"
          # Ensure that this callback returns true (required to hide menu).
          true

      callback: (key, options) ->
        key = key.split ":"
        # Get nucleotide.
        d = d3.select(options.$trigger[0]).datum()
        switch key[0]
          when "substitute" then model.geneticEngine().mutate d.idx, key[1], DNAComplement
          when "insert"     then model.geneticEngine().insert d.idx, key[1], DNAComplement

      items:
        "Substitution":
          name: "Substitution mutation"
          className: "substitution-submenu"
          items:
            "substitute:A": name: ""
            "substitute:T": name: ""
            "substitute:G": name: ""
            "substitute:C": name: ""
        "Insertion":
          name: "Insertion mutation"
          className: "insertion-submenu"
          items:
            "insert:A": name: "Insert", className: "A"
            "insert:T": name: "Insert", className: "T"
            "insert:G": name: "Insert", className: "G"
            "insert:C": name: "Insert", className: "C"
        # "Deletion": name: "Deletion mutation"