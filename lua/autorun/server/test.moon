class Player
  new: (@name) =>
    for dir in *{"north", "west", "east", "south"}
        @__base["go_#{dir}"]: =>
          print "#{@name} is going #{dir}"

Player("Lee")\go_east! --> Lee is going east
