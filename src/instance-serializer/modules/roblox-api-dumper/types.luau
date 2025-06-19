-- Define the type for a property
export type APIProperty = {
	Name: string,
	MemberType: "Property" | "Function",
	ValueType: {
		Category: string,
		Name: string,
	},
	Tags: { string }?,
	Security: {
		Read: string,
		Write: string,
	},
	Serialization: {
		CanLoad: boolean,
		CanSave: boolean,
	}?,
	Default: any?,
}

-- Define the type for a class
export type APIClass = {
	Name: string,
	Superclass: string?,
	Members: { APIProperty },
	Tags: { string }?,
}

-- Define the overall API dump structure
export type APIDump = {
	Classes: { APIClass },
	Enums: { any }, -- You can define a similar structure for Enums
}

return {}