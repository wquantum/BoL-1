--[[
	Unit Position 1.0 by Husky
	========================================================================

	Enables you to easily query the semantic position of a unit in the map.
	The jungle (as well as the river) is separated into inner and outer jungle
	to distinct roaming from warding champions.

	The following methods exist and return true if the unit is inside the
	specified area (or false otherwise):

	-- River Positions --------------------------------------------------------

	UnitPosition:inRiver(unit)
	UnitPosition:inTopRiver(unit)
	UnitPosition:inTopInnerRiver(unit)
	UnitPosition:inTopOuterRiver(unit)
	UnitPosition:inBottomRiver(unit)
	UnitPosition:inBottomInnerRiver(unit)
	UnitPosition:inBottomOuterRiver(unit)
	UnitPosition:inOuterRiver(unit)
	UnitPosition:inInnerRiver(unit)

	-- Base Positions ---------------------------------------------------------

	UnitPosition:inBase(unit)
	UnitPosition:inLeftBase(unit)
	UnitPosition:inRightBase(unit)

	-- Lane Positions ---------------------------------------------------------

	UnitPosition:onLane(unit)
	UnitPosition:onTopLane(unit)
	UnitPosition:onMidLane(unit)
	UnitPosition:onBotLane(unit)

	-- Jungle Positions -------------------------------------------------------

	UnitPosition:inJungle(unit)
	UnitPosition:inOuterJungle(unit)
	UnitPosition:inInnerJungle(unit)
	UnitPosition:inLeftJungle(unit)
	UnitPosition:inLeftOuterJungle(unit)
	UnitPosition:inLeftInnerJungle(unit)
	UnitPosition:inTopLeftJungle(unit)
	UnitPosition:inTopLeftOuterJungle(unit)
	UnitPosition:inTopLeftInnerJungle(unit)
	UnitPosition:inBottomLeftJungle(unit)
	UnitPosition:inBottomLeftOuterJungle(unit)
	UnitPosition:inBottomLeftInnerJungle(unit)
	UnitPosition:inRightJungle(unit)
	UnitPosition:inRightOuterJungle(unit)
	UnitPosition:inRightInnerJungle(unit)
	UnitPosition:inTopRightJungle(unit)
	UnitPosition:inTopRightOuterJungle(unit)
	UnitPosition:inTopRightInnerJungle(unit)
	UnitPosition:inBottomRightJungle(unit)
	UnitPosition:inBottomRightOuterJungle(unit)
	UnitPosition:inBottomRightInnerJungle(unit)
	UnitPosition:inTopJungle(unit)
	UnitPosition:inTopOuterJungle(unit)
	UnitPosition:inTopInnerJungle(unit)
	UnitPosition:inBottomJungle(unit)
	UnitPosition:inBottomOuterJungle(unit)
	UnitPosition:inBottomInnerJungle(unit)

	Changelog
	~~~~~~~~~

	1.0	- initial release with the most important map areas (jungle, river,
		  lanes and so on)
]]

-- Dependencies ----------------------------------------------------------------

require "2DGeometry"

-- Config ----------------------------------------------------------------------

mapRegions = {
	topLeftOuterJungle     = Quadrilateral(Point(1477, 4747),  Point(1502, 11232), Point(5951, 7201),   Point(3169, 4379)),
	topLeftInnerJungle     = Quadrilateral(Point(3090, 5144),  Point(2071, 5398),  Point(2088, 10702),  Point(5439, 7665)),
	topOuterRiver          = Quadrilateral(Point(5951, 7201),  Point(1502, 11232), Point(2883, 12752),  Point(7001, 7957)),
	topInnerRiver          = Quadrilateral(Point(5439, 7665),  Point(2088, 10702), Point(3454, 12086),  Point(6503, 8537)),
	topRightOuterJungle    = Quadrilateral(Point(7001, 7957),  Point(2883, 12752), Point(9465, 12832),  Point(9830, 11003)),
	topRightInnerJungle    = Quadrilateral(Point(6503, 8537),  Point(3454, 12086), Point(8825, 12137),  Point(9085, 11115)),
	bottomLeftOuterJungle  = Quadrilateral(Point(4112, 3575),  Point(6969, 6416),  Point(10922, 1920),  Point(4486, 1784)),
	bottomLeftInnerJungle  = Quadrilateral(Point(5132, 2358),  Point(4963, 3448),  Point(7499, 5798),   Point(10421, 2489)),
	bottomOuterRiver       = Quadrilateral(Point(10922, 1920), Point(6969, 6416),  Point(8192, 7207),   Point(12552, 3442)),
	bottomInnerRiver       = Quadrilateral(Point(10421, 2489), Point(7499, 5798),  Point(8742, 6731),   Point(11947, 3964)),
	bottomRightOuterJungle = Quadrilateral(Point(12552, 3442), Point(8192, 7207),  Point(10693, 10119), Point(12610, 9769)),
	bottomRightInnerJungle = Quadrilateral(Point(11947, 3964), Point(8742, 6731),  Point(11076, 9373),  Point(11998, 9234)),
	leftMidLane            = Quadrilateral(Point(3169, 4379),  Point(5951, 7201),  Point(6969, 6416),   Point(4112, 3575)),
	centerMidLane          = Quadrilateral(Point(6969, 6416),  Point(5951, 7201),  Point(7001, 7957),   Point(8192, 7207)),
	rightMidLane           = Quadrilateral(Point(8192, 7207),  Point(7001, 7957),  Point(9830, 11003),  Point(10693, 10119)),
	leftBotLane            = Quadrilateral(Point(4502, 492),   Point(4486, 1784),  Point(10922, 1920),  Point(12183, 485)),
	centerBotLane          = Quadrilateral(Point(12183, 485),  Point(10922, 1920), Point(12552, 3442),  Point(13985, 2204)),
	rightBotLane           = Quadrilateral(Point(13985, 2204), Point(12552, 3442), Point(12610, 9769),  Point(14018, 9792)),
	leftTopLane            = Quadrilateral(Point(23, 4744),    Point(9, 12584),    Point(1502, 11232),  Point(1477, 4747)),
	centerTopLane          = Quadrilateral(Point(1502, 11232), Point(9, 12584),    Point(1547, 14305),  Point(2883, 12752)),
	rightTopLane           = Quadrilateral(Point(2883, 12752), Point(1547, 14305), Point(9419, 14299),  Point(9465, 12832))
}

-- Code ------------------------------------------------------------------------

class 'UnitPosition' -- {

	-- River Positions --------------------------------------------------------

	function UnitPosition:inRiver(unit)
		return UnitPosition:inTopRiver(unit) or UnitPosition:inBottomRiver(unit)
	end

	function UnitPosition:inTopRiver(unit)
		return mapRegions["topOuterRiver"]:contains(Point(unit.x, unit.z))
	end

	function UnitPosition:inTopInnerRiver(unit)
		return mapRegions["topInnerRiver"]:contains(Point(unit.x, unit.z))
	end

	function UnitPosition:inTopOuterRiver(unit)
		return UnitPosition:inTopRiver(unit) and not UnitPosition:inTopInnerRiver(unit)
	end

	function UnitPosition:inBottomRiver(unit)
		return mapRegions["bottomOuterRiver"]:contains(Point(unit.x, unit.z))
	end

	function UnitPosition:inBottomInnerRiver(unit)
		return mapRegions["bottomInnerRiver"]:contains(Point(unit.x, unit.z))
	end

	function UnitPosition:inBottomOuterRiver(unit)
		return UnitPosition:inBottomRiver(unit) and not UnitPosition:inBottomInnerRiver(unit)
	end

	function UnitPosition:inOuterRiver(unit)
		return UnitPosition:inTopOuterRiver(unit) or UnitPosition:inBottomOuterRiver(unit)
	end

	function UnitPosition:inInnerRiver(unit)
		return UnitPosition:inTopInnerRiver(unit) or UnitPosition:inBottomInnerRiver(unit)
	end

	-- Base Positions ---------------------------------------------------------

	function UnitPosition:inBase(unit)
		return not UnitPosition:onLane(unit) and not UnitPosition:inJungle(unit) and not UnitPosition:inRiver(unit)
	end

	function UnitPosition:inLeftBase(unit)
		return UnitPosition:inBase(unit) and GetDistance({x = 50, y = 0, z = 285}, unit) < 6000
	end

	function UnitPosition:inRightBase(unit)
		return UnitPosition:inBase(unit) and GetDistance({x = 50, y = 0, z = 285}, unit) > 6000
	end

	-- Lane Positions ---------------------------------------------------------

	function UnitPosition:onLane(unit)
		return UnitPosition:onTopLane(unit) or UnitPosition:onMidLane(unit) or UnitPosition:onBotLane(unit)
	end

	function UnitPosition:onTopLane(unit)
		unitPoint = Point(unit.x, unit.z)

		return mapRegions["leftTopLane"]:contains(unitPoint) or mapRegions["centerTopLane"]:contains(unitPoint) or mapRegions["rightTopLane"]:contains(unitPoint)
	end

	function UnitPosition:onMidLane(unit)
		unitPoint = Point(unit.x, unit.z)

		return mapRegions["leftMidLane"]:contains(unitPoint) or mapRegions["centerMidLane"]:contains(unitPoint) or mapRegions["rightMidLane"]:contains(unitPoint)
	end

	function UnitPosition:onBotLane(unit)
		unitPoint = Point(unit.x, unit.z)

		return mapRegions["leftBotLane"]:contains(unitPoint) or mapRegions["centerBotLane"]:contains(unitPoint) or mapRegions["rightBotLane"]:contains(unitPoint)
	end

	-- Jungle Positions -------------------------------------------------------

	function UnitPosition:inJungle(unit)
		return UnitPosition:inLeftJungle(unit) or UnitPosition:inRightJungle(unit)
	end

	function UnitPosition:inOuterJungle(unit)
		return UnitPosition:inLeftOuterJungle(unit) or UnitPosition:inRightOuterJungle(unit)
	end

	function UnitPosition:inInnerJungle(unit)
		return UnitPosition:inLeftInnerJungle(unit) or UnitPosition:inRightInnerJungle(unit)
	end

	function UnitPosition:inLeftJungle(unit)
		return UnitPosition:inTopLeftJungle(unit) or UnitPosition:inBottomLeftJungle(unit)
	end

	function UnitPosition:inLeftOuterJungle(unit)
		return UnitPosition:inTopLeftOuterJungle(unit) or UnitPosition:inBottomLeftOuterJungle(unit)
	end

	function UnitPosition:inLeftInnerJungle(unit)
		return UnitPosition:inTopLeftInnerJungle(unit) or UnitPosition:inBottomLeftInnerJungle(unit)
	end

	function UnitPosition:inTopLeftJungle(unit)
		return mapRegions["topLeftOuterJungle"]:contains(Point(unit.x, unit.z))
	end

	function UnitPosition:inTopLeftOuterJungle(unit)
		return UnitPosition:inTopLeftJungle(unit) and not UnitPosition:inTopLeftInnerJungle(unit)
	end

	function UnitPosition:inTopLeftInnerJungle(unit)
		return mapRegions["topLeftInnerJungle"]:contains(Point(unit.x, unit.z))
	end

	function UnitPosition:inBottomLeftJungle(unit)
		return mapRegions["bottomLeftOuterJungle"]:contains(Point(unit.x, unit.z))
	end

	function UnitPosition:inBottomLeftOuterJungle(unit)
		return UnitPosition:inBottomLeftJungle(unit) and not UnitPosition:inBottomLeftInnerJungle(unit)
	end

	function UnitPosition:inBottomLeftInnerJungle(unit)
		return mapRegions["bottomLeftInnerJungle"]:contains(Point(unit.x, unit.z))
	end

	function UnitPosition:inRightJungle(unit)
		return UnitPosition:inTopRightJungle(unit) or UnitPosition:inBottomRightJungle(unit)
	end

	function UnitPosition:inRightOuterJungle(unit)
		return UnitPosition:inTopRightOuterJungle(unit) or UnitPosition:inBottomRightOuterJungle(unit)
	end

	function UnitPosition:inRightInnerJungle(unit)
		return UnitPosition:inTopRightInnerJungle(unit) or UnitPosition:inBottomRightInnerJungle(unit)
	end

	function UnitPosition:inTopRightJungle(unit)
		return mapRegions["topRightOuterJungle"]:contains(Point(unit.x, unit.z))
	end

	function UnitPosition:inTopRightOuterJungle(unit)
		return UnitPosition:inTopRightJungle(unit) and not UnitPosition:inTopRightInnerJungle(unit)
	end

	function UnitPosition:inTopRightInnerJungle(unit)
		return mapRegions["topRightInnerJungle"]:contains(Point(unit.x, unit.z))
	end

	function UnitPosition:inBottomRightJungle(unit)
		return mapRegions["bottomRightOuterJungle"]:contains(Point(unit.x, unit.z))
	end

	function UnitPosition:inBottomRightOuterJungle(unit)
		return UnitPosition:inBottomRightJungle(unit) and not UnitPosition:inBottomRightInnerJungle(unit)
	end

	function UnitPosition:inBottomRightInnerJungle(unit)
		return mapRegions["bottomRightInnerJungle"]:contains(Point(unit.x, unit.z))
	end

	function UnitPosition:inTopJungle(unit)
		return UnitPosition:inTopLeftJungle(unit) or UnitPosition:inTopRightJungle(unit)
	end

	function UnitPosition:inTopOuterJungle(unit)
		return UnitPosition:inTopLeftOuterJungle(unit) or UnitPosition:inTopRightOuterJungle(unit)
	end

	function UnitPosition:inTopInnerJungle(unit)
		return UnitPosition:inTopLeftInnerJungle(unit) or UnitPosition:inTopRightInnerJungle(unit)
	end

	function UnitPosition:inBottomJungle(unit)
		return UnitPosition:inBottomLeftJungle(unit) or UnitPosition:inBottomRightJungle(unit)
	end

	function UnitPosition:inBottomOuterJungle(unit)
		return UnitPosition:inBottomLeftOuterJungle(unit) or UnitPosition:inBottomRightOuterJungle(unit)
	end

	function UnitPosition:inBottomInnerJungle(unit)
		return UnitPosition:inBottomLeftInnerJungle(unit) or UnitPosition:inBottomRightInnerJungle(unit)
	end
-- }
