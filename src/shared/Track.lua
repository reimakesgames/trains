-- This module allows you to create a track object, which is a collection of
-- points that can be used to create a path for a vehicle to follow.
-- It will always follow the path in the order that the points were added.
-- it will always be in a grid too, specifically 2x2 units. (factorio lol)

local Track = {}
Track.__index = Track

function Track.new()

end

return Track
