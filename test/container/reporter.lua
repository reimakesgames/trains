--[[
	The TextReporter uses the results from a completed test to output text to
	standard output and TestService.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local TestEZ = require(Packages.TestEZ)

local TestService = game:GetService("TestService")

local TestEnum = TestEZ.TestEnum

local INDENT = (" "):rep(3)
local STATUS_SYMBOLS = {
	[TestEnum.TestStatus.Success] = "\\e[1;32m+\\e[0m",
	[TestEnum.TestStatus.Failure] = "\\e[1;31m-\\e[0m",
	[TestEnum.TestStatus.Skipped] = "\\e[1;33m~\\e[0m"
}
local UNKNOWN_STATUS_SYMBOL = "?"

local TextReporter = {}

local function compareNodes(a, b)
	return a.planNode.phrase:lower() < b.planNode.phrase:lower()
end

local function reportNode(node, buffer, level)
	buffer = buffer or {}
	level = level or 0

	if node.status == TestEnum.TestStatus.Skipped then
		return buffer
	end

	local line

	if node.status then
		local symbol = STATUS_SYMBOLS[node.status] or UNKNOWN_STATUS_SYMBOL

		line = ("%s[%s] %s"):format(
			INDENT:rep(level),
			symbol,
			node.planNode.phrase
		)
	else
		line = ("%s%s"):format(
			INDENT:rep(level),
			node.planNode.phrase
		)
	end

	table.insert(buffer, line)
	table.sort(node.children, compareNodes)

	for _, child in ipairs(node.children) do
		reportNode(child, buffer, level + 1)
	end

	return buffer
end

local function reportRoot(node)
	local buffer = {}
	table.sort(node.children, compareNodes)

	for _, child in ipairs(node.children) do
		reportNode(child, buffer, 0)
	end

	return buffer
end

local function report(root)
	local buffer = reportRoot(root)

	return table.concat(buffer, "\n")
end

function TextReporter.report(results)
	local resultBuffer = {
		"Test results:",
		report(results),
		("\\e[1;32m%d\\e[0m passed, \\e[1;31m%d\\e[0m failed, \\e[1;33m%d\\e[0m skipped"):format(
			results.successCount,
			results.failureCount,
			results.skippedCount
		)
	}

	print(table.concat(resultBuffer, "\n"))

	if results.failureCount > 0 then
		print(("%d test nodes reported failures."):format(results.failureCount))
	end

	if #results.errors > 0 then
		print("Errors reported by tests:")
		print("")

		for _, message in ipairs(results.errors) do
			TestService:Error(message)

			-- Insert a blank line after each error
			print("")
		end
	end
end

return TextReporter