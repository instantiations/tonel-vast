Class {
	#name : 'TonelTextConstants',
	#superclass : 'SharedPool',
	#classVars : [
		'TonelMsg17',
		'TonelMsg04',
		'TonelMsg29',
		'TonelMsg01',
		'TonelMsg03',
		'TonelMsg16',
		'TonelMsg18',
		'TonelMsg27',
		'TonelMsg02',
		'TonelMsg31',
		'TonelMsg14',
		'TonelMsg11',
		'TonelMsg28',
		'TonelMsg13',
		'TonelMsg05',
		'TonelMsg12',
		'TonelMsg24',
		'TonelMsg21',
		'TonelMsg30',
		'TonelMsg09',
		'TonelMsg23',
		'TonelMsg10',
		'TonelMsg22',
		'TonelMsg15',
		'TonelMsg07',
		'TonelMsg20',
		'TonelMsg06',
		'TonelMsg19',
		'TonelMsg08',
		'TonelMsg25'
	],
	#type : 'variable',
	#category : 'TonelBaseApp'
}

{
	#category : 'Initializing'
}
TonelTextConstants class >> initialize [
	TonelMsg23 := 'Selected Tonel Packages'.
	TonelMsg24 := 'Name: %1%0Author: %2%0Time: %3, %4%0%0%5'.
	TonelMsg15 := 'Select Tonel Packages to be imported as VAST Applications'.
	TonelMsg11 := 'Enter the version name to be used for imported classes and applications'.
	TonelMsg29 := 'Available applications'.
	TonelMsg02 := 'Export Applications as Tonel packages...'.
	TonelMsg20 := 'Loading... <1s>'.
	TonelMsg13 := 'Please select the prequisites for %1 (chains will be resolved after selection)'.
	TonelMsg14 := 'The selected Tonel repository does not contain a valid sources directory.'.
	TonelMsg08 := 'You need to choose a base edition from which to create %1'.
	TonelMsg07 := '%1 %2'.
	TonelMsg19 := 'The following subapplications were not imported: '.
	TonelMsg16 := 'The following source failed to compile (all double quotes have been doubled):'.
	TonelMsg10 := 'Missing superclass for %1'.
	TonelMsg22 := 'Available Tonel Packages'.
	TonelMsg31 := 'Select a target path'.
	TonelMsg27 := 'Select applications to export in Tonel format'.
	TonelMsg28 := 'Select which applications you want to export in Tonel format to a specific'.
	TonelMsg12 := 'Select Tonel repository path'.
	TonelMsg05 := 'The SubApplication %1 exists in the image, but is a subapplication of %2, not %3'.
	TonelMsg17 := '^ self halt: ''The source for this method failed to compile'' '.
	TonelMsg18 := 'Could not load base edition of %1. Load aborted.'.
	TonelMsg01 := 'Import Applications from Tonel packages...'.
	TonelMsg30 := 'Applications to be exported'.
	TonelMsg03 := '%1 extends %2, which is not defined in the image'.
	TonelMsg04 := '%1 defines %2 as a subclass of %3, which is not defined in the image'.
	TonelMsg25 := 'The selected Tonel repository is not valid or does not contain any package.'.
	TonelMsg06 := 'Application %1 exists but is not loaded. Please choose a base version.'.
	TonelMsg09 := 'Base edition for %1 is managed by %2. You are currently %3 and cannot create new editions of the application.'.
	TonelMsg21 := 'The following Tonel Packages will be imported as VAST Applications'.

]
