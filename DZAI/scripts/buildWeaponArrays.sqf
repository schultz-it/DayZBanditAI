/*
	buildWeaponArrays
	
	Description:
	
	Last updated: 4:00 PM 6/13/2013
*/

private ["_bldgClasses","_weapons","_lootItem","_DZAI_bannedWeapons","_unwantedWeapons","_versionDZ","_lootList"];

diag_log "Building DZAI weapon arrays using CfgBuildingLoot data.";

//Determine version of DayZ being used.
_versionDZ = getText (configFile >> "CfgMods" >> "DayZ" >> "version");
//diag_log format ["DEBUG :: Detected DayZ version %1.",_versionDZ];
_lootList = "";
if (_versionDZ == "1.7.7") then {
	_lootList = "lootType";
} else {
	_lootList = "itemType";
};

//_bldgClasses = [["Residential","Farm","Supermarket"],["Military"],["MilitarySpecial"],["HeliCrash"]];	//[[(weapongrade 0)],[(weapongrade 1)],[(weapongrade 2)],[(weapongrade 3)]]
_DZAI_bannedWeapons = ["Crossbow_DZ","Crossbow"];

_bldgClasses = _this select 0;
_unwantedWeapons = _this select 1;

//Add DZAI-banned weapons to unwanted weapons list.
for "_i" from 0 to ((count _DZAI_bannedWeapons) -1) do {
	if !((_DZAI_bannedWeapons select _i) in _unwantedWeapons) then {
		_unwantedWeapons set [(count _unwantedWeapons),(_DZAI_bannedWeapons select _i)];
	};
};
diag_log format ["List of weapons to be removed from DZAI classname tables: %1",_unwantedWeapons];

//Reset weapon arrays
DZAI_Pistols0 = [];
DZAI_Pistols1 = [];
DZAI_Pistols2 = [];
DZAI_Pistols3 = [];

DZAI_Rifles0 = [];
DZAI_Rifles1 = [];
DZAI_Rifles2 = [];
DZAI_Rifles3 = [];

//Build the weapon arrays.
for "_i" from 0 to (count _bldgClasses - 1) do {					//_i = weapongrade
	for "_j" from 0 to (count (_bldgClasses select _i) - 1) do {	//If each weapongrade has more than 1 building class, investigate them all
		private["_bldgLoot"];
		_bldgLoot = [] + getArray (configFile >> "cfgBuildingLoot" >> ((_bldgClasses select _i) select _j) >> _lootList);
		for "_k" from 0 to (count _bldgLoot - 1) do {				
			_lootItem = _bldgLoot select _k;
			if ((_lootItem select 1) == "weapon") then {			//Build an array of "weapons", then categorize them as rifles or pistols, then sort them into the correct weapon grade.
				private ["_weaponItem","_weaponMags"];
				_weaponItem = _lootItem select 0;
				_weaponMags = count (getArray (configFile >> "cfgWeapons" >> _weaponItem >> "magazines"));
				if (_weaponMags > 0) then {							//Consider an item as a "weapon" if it has at least one magazine type.
					if !(_weaponItem in _unwantedWeapons) then {
						if ((getNumber (configFile >> "CfgWeapons" >> _weaponItem >> "type")) == 1) then {
							call compile format ["DZAI_Rifles%1 set [(count DZAI_Rifles%1),'%2'];",_i,_weaponItem];
						} else {
							if ((getNumber (configFile >> "CfgWeapons" >> _weaponItem >> "type")) == 2) then {
								call compile format ["DZAI_Pistols%1 set [(count DZAI_Pistols%1),'%2'];",_i,_weaponItem];
							};
						};
					};
				};
			};
		};
		sleep 0.1;
	};
};

//Because heli-crash sites don't usually have pistol loot, it may be necessary to populate it with pistol classnames from the MilitarySpecial table.
if ((count DZAI_Pistols3) == 0) then {
	diag_log "DZAI_Pistols3 is empty. Populating with entries from DZAI_Pistols2.";
	DZAI_Pistols3 = [] + DZAI_Pistols2;
};

//In case the mod has no HeliCrash loot tables...
if ((count DZAI_Rifles3) == 0) then {
	diag_log "DZAI_Rifles3 is empty. Populating with entries from DZAI_Rifles2.";
	DZAI_Rifles3 = [] + DZAI_Rifles2;
};

//Combine lowest pistol and rifle tiers
for "_i" from 0 to ((count DZAI_Pistols0) - 1) do {DZAI_Rifles0 set [(count DZAI_Rifles0),(DZAI_Pistols0 select _i)];};

if (DZAI_debugLevel > 0) then {
	//Display finished weapon arrays
	diag_log format ["Contents of DZAI_Pistols0: %1",DZAI_Pistols0];
	diag_log format ["Contents of DZAI_Pistols1: %1",DZAI_Pistols1];
	diag_log format ["Contents of DZAI_Pistols2: %1",DZAI_Pistols2];
	diag_log format ["Contents of DZAI_Pistols3: %1",DZAI_Pistols3];

	diag_log format ["Contents of DZAI_Rifles0: %1",DZAI_Rifles0];
	diag_log format ["Contents of DZAI_Rifles1: %1",DZAI_Rifles1];
	diag_log format ["Contents of DZAI_Rifles2: %1",DZAI_Rifles2];
	diag_log format ["Contents of DZAI_Rifles3: %1",DZAI_Rifles3];
};

diag_log "DZAI weapon classname tables created.";

DZAI_weaponsInitialized = true;
