; -=PBEdit 1.13=-
; ---------------------------------------------------------------------
; a canvas-based text editor -> PureBasic only <- no external libraries
;
; Features
;	- Basic editing
;	- Mouse support
;	- Multicursor
;	- Split view
;	- Syntax highlighting
;	- Indentation (none, block, automatic)
;	- Autocomplete
;	- Folding
;	- Case correction
;	- Linenumbers
;	- "real" tabs or spaces
;	- Undo / Redo
;	- Drag & Drop
;	- Find / Replace Dialog (Regular Expressions supported)
;	- Bookmarks
;	- Zooming
;	- Repeated selections
;	- Horizontal / Vertical Scrollbars (optional)
;	- Customizable (via xml)
;	- DPI aware (Set "Enable DPI aware executable" in compiler options)
;	- Mark matching or missing keywords and brackets
;	- Line continuation
;	- Beautify textline after return
;
;	v1.0.1
;	added:		multilanguage support (language.cfg file)
;
;	v1.0.2
;	added:		settings file (PBEdit.xml)
;
;	v1.0.3 		bugs fixed
;
;	v1.0.4
;	fixed:		bug in horizontal scroll (last chars of long textline not visible)
;	fixed:		bug when inserting text with multiple cursors
;	fixed:		missing colors in settings.xml
;	fixed:		beautify procedure removed indentation when in block-mode
;	changed:	redraw of cursor only if needed (avoid flickering)
;	changed:	default style is black/white
;	changed:	tokenizing and styling simplified
;	added:		enhanced character table (use all 65535 characters instead of only 255)
;	added:		if needed, set #TE_CharRange to 65536
;
;	v1.0.5
;	changed:	the cursor now has its own timer and the scroll timer is only activated if needed
;	added:		french translation (thx, Mesa!)
;
;	v1.0.6
;	fixed:		a few scrolling related issues
;	changed:	removed the "ID" Parameter from the Procedure "Editor_New". The return value now is a pointer to the TE_STRUCT (not the canvas ID anymore)
;	added:		PostEvent to signal cursor changes (#TE_Event_Cursor) or selection changes (#TE_Event_Selection)				
;
;	v1.0.7
;	fixed:		wrong filename of default languageFile
;	fixed:		faulty line continuation
;	fixed:		autocomplete not showing strings starting with # or * (if flag "enableDictionary" is set to true)
;	fixed:		syntax highlight issues
;	fixed:		indentationLines drawn multiple times
;	added:		flag "enableAutoClosingBracket": enable / disable adding of closing brackets
;	added:		flag "enableZooming": enable / disable zooming
;	added:		Ctrl+Tab - cycle through views
;
;	v1.0.8
;	fixed:		bug in Procedure Selection_Move that led to adding of blank lines and messed with the undo function
;	fixed:		multicursor with overwrite-mode didn't work properly with multiple cursors set in same textline
;	fixed:		bug in display of the AutoComplete list
;	changed:	the new AutoComplete list is drawn directly on the canvas (no separate Window and ListViewGadget anymore)
;
;	v1.0.9
;	fixed:		scrolling after a textblock is unfolded
;	fixed:		typo (#TE_Redraw_ChangedLined to #TE_Redraw_ChangedLines)
;	fixed:		in find/replace dialog: flags #TE_Find_NoComments and #TE_Find_NoStrings not working
;	fixed:		indentation bug (indentation of keywords inside comments, strings etc.)
;	fixed:		scollbar bug (interaction between horizontal and vertical scrollbar didn't work properly)
;	changed:	renamed PBEdit_GetFirstSelectedLineNr to PBEdit_GetCursorLineNr
;	changed:	renamed PBEdit_GetFirstSelectedCharNr to PBEdit_GetCursorCharNr
;	changed:	renamed PBEdit_GetLastSelectedLineNr to PBEdit_GetSelectionLineNr
;	changed:	renamed PBEdit_GetLastSelectedCharNr to PBEdit_GetSelectionCharNr
;	added:		PBEdit_IsGadget(ID): test if this ID is valid
;	added:		PBEdit_FreeGadget(ID): remove editor and free used resources
;	added:		in PBEdit_SetSelection: if LineNr < 1 clear selection
;	added:		PBEdit_SelectionCharCount(ID): return the number of selected characters
;	added:		Folding_ToggleAll(*te.TE_STRUCT): toggle all folds
;	added:		flag "enableReadOnly": if set to true, the editor is read only (no changes of the text allowed)
;				
;	v1.0.10
;	fixed:		first lineNr was zero after initialization
;	fixed:		bug in calculation of vertical scrollbar position
;	changed:	flags in the TE_STRUCT are now a combination of "binary bit flags"
;	changed:	renamed TE_CURSORSTATE\state to TE_CURSORSTATE\dragDropMode
;	added:		PBEdit_SetFlag(ID, Flag, Value): set or clear the specified flag (eg. PBEdit_SetFlag(EditorID, #TE_EnableReadOnly, 1))
;	added:		PBEdit_GetFlag(ID, Flag): get the specified flag
;	added:		PBEdit_SetGadgetFont(ID, FontName$, FontHeight = 0, FontStyle = 0)
;	added:		TE_STRUCT\foldChar (default: 1): a special character that indicates the foldstate of a newly inserted textline
;	added:		horizontal autoscroll
;
;	v1.11
;	fixed:		unintended scrolling after a textblock is folded/unfolded
;	fixed:		folded textblock not unfolded, when text is edited
;	fixed:		numpad return key not responding in linux
;	fixed:		typo "laguage" renamed to "language"
;	fixed:		autocomplete scrollbar not working
;	changed:	the version number now has only two parts
;	changed:	CanvasGadget with flag "#PB_Canvas_Container". The ScrollBars now are added to the views CanvasGadget
;	changed:	added a ContainerGadget as parent for all views
;	changed:	added Procedure PBEdit_Container(ID) to get the ID of the ContainerGadget
;	changed:	removed x,y,width,height from TE_STRUCT since these values can be obtained from the ContainerGadget
;	changed:	#TE_SyntaxCheck to #TE_SyntaxHighlight
;	changed:	#TE_Flag_... to #TE_Syntax_... and #TE_Parser_...
;	changed:	TE_COLORSCHEME/defaultTextColor to TE_COLORSCHEME/defaultText
;	changed:	TE_COLORSCHEME/selectedTextColor to TE_COLORSCHEME/selectedText
;	changed:	the blinking of the cursor is now controlled via thread (Draw_CursorThread) - enable "Create threadsafe executable" in the compiler options!
;				if the value "cursorBlinkDelay" in the settings file is "0" the cursor is not blinking at all
;	changed:	reduced unnecessary redrawing of unmodified textlines (less CPU usage when idle)
;	changed:	renamed procedure Event_Resize to Editor_Resize
;	changed:	improved speed of dictionary update
;	changed:	improved syntax highlighting
;	added:		PostEvent #TE_Event_Redraw with #TE_EventType_RedrawAll or #TE_EventType_RedrawChangedLines
;	added:		Structure TE_REPEATEDSELECTION
;	added:		TE_REPEATEDSELECTION\minCharacterCount: number of consecutive characters that have to be selected to highlight repeated selections
;	added:		flag #TE_RepeatedSelection_WholeWord: highlight the whole word if Nr. of selected characters >= TE_REPEATEDSELECTION\minCharacterCount
;	added:		flag #TE_EnableHorizontalFoldLines: if true, display a horizontal line over and under a foldable textblock
;	added:		flag #TE_EnableSelection: enable/disable selecting of text
;	added:		flag #TE_EnableAlwaysShowSelection: enable/disable display selection if not active gadget
;	added:		flag #TE_EnableAutoClosingKeyword: enable/disable insertion of closing keyword after Tab-Key is pressed twice
;
;	v1.12
;	fixed:		jump to bookmark (F2 key) didn't jump to the correct line
;	fixed:		wrong indentation when the previous textline was a split line (has line continuation)
;	changed:	renamed procedure Draw_CursorThread to Cursor_Thread
;	changed:	the Cursor_Thread is posting the event #TE_Event_CursorBlink to the active editor
;				the actual redrawing of the cursor takes place in the new Procedure "Event_Cursor".
;				at the moment the blink delay is set to a fixed value (500 ms).
;				
;	v1.13
;	fixed:		mouse selection related issues
;	fixed:		autocomplete scrollbar position
;	fixed:		find/replace too slow due to permanent dictionary updates
;	fixed:		typo #TE_Font_Undelined = #TE_Font_Underlined
;	fixed:		case correction not undoable
;	fixed:		ProcedureReturn before PopListPosition in Procedure Position_InsideComment
;	added:		Ctrl+H - replace shortcut
;	added:		flag #TE_EnableUndo: enable/disable undo
;	added:		Procedure Textline_ChangeText: change text in place
;	added:		flag #TE_Undo_ChangeText
;	changed:	copy/paste with multicursor: each cursor now has it's own clipboard
;	changed:	Procedure Event_Mouse now calling Event_Mouse_LeftButtonDown, Event_Mouse_LeftButtonUp and Event_Mouse_Move
;	changed:	renamed TE_STRUCT\autoCompleteList to TE_STRUCT\dictionary
;	changed:	optimization in Procedure Indentation_Range
;	changed:	optimization in Procedure Folding_UnfoldTextline
;
; ----------------------------------------------------------------------------------
;
;	MIT License
;	
;	Copyright (c) 2023 Mr.L
;	
;	Permission is hereby granted, free of charge, to any person obtaining a copy
;	of this software and associated documentation files (the "Software"), to deal
;	in the Software without restriction, including without limitation the rights
;	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;	copies of the Software, and to permit persons to whom the Software is furnished
;	to do so, subject to the following conditions:
; 
;	The above copyright notice and this permission notice shall be included in all
;	copies or substantial portions of the Software.
; 
;	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
;	INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
;	PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
;	HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
;	OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
;	SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.



DeclareModule _PBEdit_	
	#TE_DEBUGDRAW = 0	
	#TE_CharSize = SizeOf(Character)
	#TE_VectorDrawAdjust = 0.5
	#TE_VectorDrawWidth = 0.5
	#TE_CharRange = 256
	;#TE_CharRange = 65536
	#TE_MaxCursors = 5000
	#TE_Ignore = -2
	#TE_Shortcut_PadReturn = 65421; linux key number of Return Key on Number Pad
	
	Enumeration #PB_Event_FirstCustomValue
		#TE_Event_Redraw
		#TE_Event_Cursor
		#TE_Event_Selection
		#TE_Event_CursorBlink
		#TE_EventType_RedrawAll
		#TE_EventType_RedrawChangedLines
		#TE_EventType_Add
		#TE_EventType_Change
		#TE_EventType_Remove
	EndEnumeration
	
	EnumerationBinary
		#TE_EnableUndo
		#TE_EnableScrollBarHorizontal
		#TE_EnableScrollBarVertical
		#TE_EnableZooming
		#TE_EnableStyling
		#TE_EnableLineNumbers
		#TE_EnableWordWrap
		#TE_EnableShowCurrentLine
		#TE_EnableSelection
		#TE_EnableFolding
		#TE_EnableIndentation
		#TE_EnableCaseCorrection
		#TE_EnableIndentationLines
		#TE_EnableHorizontalFoldLines
		#TE_EnableShowWhiteSpace
		#TE_EnableAutoComplete
		#TE_EnableAutoClosingBracket
		#TE_EnableAutoClosingKeyword
		#TE_EnableDictionary
		#TE_EnableSyntaxHighlight
		#TE_EnableBeautify
		#TE_EnableMultiCursor
		#TE_EnableMultiCursorPaste
		#TE_EnableSplitScreen
		#TE_EnableSelectPastedText
		#TE_EnableRepeatedSelection
		#TE_EnableReadOnly
		#TE_EnableAlwaysShowSelection		
	EndEnumeration
	
	EnumerationBinary
		#TE_Redraw_ChangedLines
		#TE_Redraw_All
	EndEnumeration
	
	Enumeration 1
		#TE_Style_None
		#TE_Style_Keyword
		#TE_Style_Function
		#TE_Style_Structure
		#TE_Style_Text
		#TE_Style_String
		#TE_Style_Quote
		#TE_Style_Comment
		#TE_Style_Number
		#TE_Style_Pointer
		#TE_Style_Address
		#TE_Style_Constant
		#TE_Style_Operator
		#TE_Style_Backslash
		#TE_Style_Comma
		#TE_Style_Bracket
		#TE_Style_RepeatedSelection
		#TE_Style_CodeMatch
		#TE_Style_CodeMismatch
		#TE_Style_BracketMatch
		#TE_Style_BracketMismatch
		#TE_Style_Label
	EndEnumeration
	
	Global Dim StyleEnumName.s(64)
	StyleEnumName(#TE_Style_None) = "None"
	StyleEnumName(#TE_Style_Keyword) = "Keyword"
	StyleEnumName(#TE_Style_Function) = "Function"
	StyleEnumName(#TE_Style_Structure) = "Structure"
	StyleEnumName(#TE_Style_Text) = "Text"
	StyleEnumName(#TE_Style_String) = "String"
	StyleEnumName(#TE_Style_Quote) = "Quote"
	StyleEnumName(#TE_Style_Comment) = "Comment"
	StyleEnumName(#TE_Style_Number) = "Number"
	StyleEnumName(#TE_Style_Pointer) = "Pointer"
	StyleEnumName(#TE_Style_Address) = "Address"
	StyleEnumName(#TE_Style_Constant) = "Constant"
	StyleEnumName(#TE_Style_Operator) = "Operator"
	StyleEnumName(#TE_Style_Backslash) = "Backslash"
	StyleEnumName(#TE_Style_Comma) = "Comma"
	StyleEnumName(#TE_Style_Bracket) = "Bracket"
	StyleEnumName(#TE_Style_RepeatedSelection) = "RepeatedSelection"
	StyleEnumName(#TE_Style_CodeMatch) = "CodeMatch"
	StyleEnumName(#TE_Style_CodeMismatch) = "CodeMismatch"
	StyleEnumName(#TE_Style_BracketMatch) = "BracketMatch"
	StyleEnumName(#TE_Style_BracketMismatch) = "BracketMismatch"
	StyleEnumName(#TE_Style_Label) = "Label"
	
	Enumeration
		#TE_Font_Normal
		#TE_Font_Bold
		#TE_Font_Italic
		#TE_Font_Underlined
		#TE_Font_StrikeOut
	EndEnumeration
	
	Enumeration
		#TE_Token_Unknown
		#TE_Token_Whitespace			;  Space or Tab
		#TE_Token_Text
		#TE_Token_Number
		#TE_Token_Operator				;  + - / & | ! ~
		#TE_Token_Compare				;  < >
		#TE_Token_Backslash
		#TE_Token_Point
		#TE_Token_Equal
		#TE_Token_Comma
		#TE_Token_Colon					;  :
		#TE_Token_BracketOpen			;  ( [ {
		#TE_Token_BracketClose			;  ) ] }
		#TE_Token_String				;  "..."
		#TE_Token_Quote					;  '...'
		#TE_Token_Comment				;  ;...
		#TE_Token_Uncomment				;  ;...
		#TE_Token_EOL					; End of line
	EndEnumeration
	
	Global Dim TokenEnumName.s(64)
	TokenEnumName(#TE_Token_Unknown) = "Unknown"
	TokenEnumName(#TE_Token_Whitespace) = "WhiteSpace"
	TokenEnumName(#TE_Token_Text) = "Text"
	TokenEnumName(#TE_Token_Number) = "Number"
	TokenEnumName(#TE_Token_Operator) = "Operator"
	TokenEnumName(#TE_Token_Compare) = "Compare"
	TokenEnumName(#TE_Token_Backslash) = "Backslash"
	TokenEnumName(#TE_Token_Point) = "Point"
	TokenEnumName(#TE_Token_Equal) = "Equal"
	TokenEnumName(#TE_Token_Comma) = "Comma"
	TokenEnumName(#TE_Token_Colon) = "Colon"
	TokenEnumName(#TE_Token_BracketOpen) = "BracketOpen"
	TokenEnumName(#TE_Token_BracketClose) = "BracketClose"
	TokenEnumName(#TE_Token_String) = "String"
	TokenEnumName(#TE_Token_Quote) = "Quote"
	TokenEnumName(#TE_Token_Comment) = "Comment"
	TokenEnumName(#TE_Token_EOL) = "EOL"
	
	EnumerationBinary
		#TE_Styling_UpdateFolding
		#TE_Styling_UpdateIndentation
		#TE_Styling_UnfoldIfNeeded
		#TE_Styling_CaseCorrection
		#TE_Styling_NoUndo
		#TE_Styling_All = #TE_Styling_UpdateFolding | #TE_Styling_UpdateIndentation | #TE_Styling_UnfoldIfNeeded | #TE_Styling_CaseCorrection
	EndEnumeration
	
	EnumerationBinary
		#TE_Find_Next
		#TE_Find_Previous
		#TE_Find_StartAtCursor
		#TE_Find_CaseSensitive
		#TE_Find_WholeWords
		#TE_Find_NoComments
		#TE_Find_NoStrings
		#TE_Find_RegEx
		#TE_Find_InsideSelection
		#TE_Find_Replace
		#TE_Find_ReplaceAll
	EndEnumeration
	
	EnumerationBinary
		#TE_RepeatedSelection_NoCase
		#TE_RepeatedSelection_WholeWord
	EndEnumeration
	
	Enumeration
		#TE_Indentation_None
		#TE_Indentation_Block
		#TE_Indentation_Auto
	EndEnumeration
	
	Enumeration
		#TE_Color_Text = -1
	EndEnumeration
	
	Enumeration
		#TE_Folding_Unfolded = 1
		#TE_Folding_Folded = 2
		#TE_Folding_End = -1
	EndEnumeration
	
	Enumeration
		#TE_Text_LowerCase
		#TE_Text_UpperCase
	EndEnumeration
	
	Enumeration 1
		#TE_Undo_Start
		#TE_Undo_AddText
		#TE_Undo_DeleteText
		#TE_Undo_ChangeText
		#TE_Undo_AddRemark
		#TE_Undo_DeleteRemark
	EndEnumeration
	
	Enumeration 1
		#TE_MousePosition_LineNumber
		#TE_MousePosition_FoldState
		#TE_MousePosition_TextArea
		#TE_MousePosition_AutoComplete
		#TE_MousePosition_AutoCompleteScrollBar
	EndEnumeration
	
	Enumeration
		#TE_View_SplitHorizontal
		#TE_View_SplitVertical
	EndEnumeration
	
	Enumeration 1
		#TE_Cursor_Normal
		#TE_Cursor_DragDrop
		#TE_Cursor_DragDropForbidden
	EndEnumeration
	
	Enumeration
		#TE_Timer_Scroll
	EndEnumeration
	
	Enumeration
		#TE_CursorState_Idle = -1
		#TE_CursorState_DragCancel = -2
		#TE_CursorState_DragMove = 1
		#TE_CursorState_DragCopy = 2
	EndEnumeration
	
	Enumeration
		#TE_Autocomplete_FindAtBegind
		#TE_Autocomplete_FindAny
	EndEnumeration
	
	Enumeration 100
		#TE_Menu_Cut
		#TE_Menu_Copy
		#TE_Menu_Paste
		#TE_Menu_InsertComment
		#TE_Menu_RemoveComment
		#TE_Menu_FormatIndentation
		#TE_Menu_ToggleFold
		#TE_Menu_ToggleAllFolds
		#TE_Menu_SelectAll
		#TE_Menu_SplitViewHorizontal
		#TE_Menu_SplitViewVertical
		#TE_Menu_UnsplitView
		#TE_Menu_Beautify
		
		#TE_Menu_ReturnKey
		#TE_Menu_EscapeKey
		#TE_Menu_F3Key
		#TE_Menu_ShiftF3Key
	EndEnumeration
	
	EnumerationBinary
		#TE_Marker_Bookmark
		#TE_Marker_Breakpoint
	EndEnumeration
	
	Enumeration 1
		#TE_Remark_Text
		#TE_Remark_Error
		#TE_Remark_Warning
	EndEnumeration
	
	EnumerationBinary
		#TE_Syntax_Start
		#TE_Syntax_End
		#TE_Syntax_Container
		#TE_Syntax_Procedure
		#TE_Syntax_Return
		#TE_Syntax_Loop
		#TE_Syntax_Break
		#TE_Syntax_Continue
		#TE_Syntax_Compiler
		#TE_Syntax_Macro
	EndEnumeration
	
	EnumerationBinary
		#TE_Parser_Multiline
		#TE_Parser_SkipWhiteSpace
		#TE_Parser_SkipBlankLines
		#TE_Parser_IgnoreComments
		#TE_Parser_TextOnly
		#TE_Parser_State_EOL
		#TE_Parser_State_EOF
	EndEnumeration
	
	Enumeration
		#TE_Scrollbar_Enabled = 1
		#TE_Scrollbar_AlwaysOn = 2
	EndEnumeration
	
	Enumeration
		#TE_WordWrap_None
		#TE_WordWrap_Chars
		#TE_WordWrap_Size
		#TE_WordWrap_Border
	EndEnumeration
	
	Structure TE_COLORSCHEME
		defaultText.i
		selectedText.i
		cursor.i
		inactiveBackground.i
		currentBackground.i
		selectionBackground.i
		currentLine.i
		currentLineBackground.i
		currentLineBorder.i
		inactiveLineBackground.i
		indentationGuides.i
		horizontalFoldLines.i
		lineNr.i
		currentLineNr.i
		lineNrBackground.i
		foldIcon.i
		foldIconBorder.i
		foldIconBackground.i
	EndStructure
	
	Structure TE_TEXTSTYLE
		fColor.i
		bColor.i
		uColor.i
		fontNr.i
	EndStructure
	
	Structure TE_TOKEN
		type.a
		charNr.l
		*text.Character
		size.l
	EndStructure
	
	Structure TE_FONT
		name.s
		nr.i
		id.i
		size.i
		height.i
		style.i
		Array width.i(#TE_CharRange)
	EndStructure
	
	Structure TE_PARSER
		*textline.TE_TEXTLINE
		*token.TE_TOKEN
		Array tokenType.c(#TE_CharRange)
		lineNr.i
		tokenIndex.i
		state.i
	EndStructure
	
	Structure TE_SYNTAX
		keyword.s
		flags.i
		Map before.TE_SYNTAX()
		Map after.TE_SYNTAX()
	EndStructure
	
	Structure TE_KEYWORDITEM
		name.s
		length.i
	EndStructure
	
	Structure TE_AUTOCOMPLETE
		List entry.TE_KEYWORDITEM()
		
		x.d
		y.d
		width.d
		height.d
		
		scrollBarWidth.d
		
		index.i
		scrollLine.i
		scollMousePos.i
		scrollDistance.d
		lastScrollPos.i
		
		text.s
		minCharacterCount.i
		rows.i
		maxRows.i
		mode.i
		keyword.s
		lastKeyword.s
		
		isVisible.b
		isScrollBarVisible.b
		isScrolling.b
	EndStructure
	
	Structure TE_KEYWORD
		name.s
		style.b
		foldState.b
		indentationBefore.b
		indentationAfter.b
		caseCorrection.b
	EndStructure
	
	Structure TE_INDENTATIONPOS
		*textLine.TE_TEXTLINE
		charNr.i
	EndStructure
	
	Structure TE_POSITION
		*textline.TE_TEXTLINE
		lineNr.i
		visibleLineNr.i
		charNr.i
		charX.i
		currentX.i
		width.i
	EndStructure
	
	Structure TE_RANGE
		pos1.TE_POSITION
		pos2.TE_POSITION
	EndStructure
	
	Structure TE_CURSORSTATE
		overwrite.i
		compareMode.i
		
		time.i
		
		blinkDelay.i
		blinkSuspend.i
		blinkState.i
		
		buttons.i
		modifiers.i
		
		clickSpeed.i					; in Event_Mouse
		clickCount.i					; in Event_Mouse:	used to detect 'double/tripple/... -click'
		firstClickTime.i				; in Event_Mouse
		firstClickX.i					; in Event_Mouse:	first x-position of the mouse
		firstClickY.i					; in Event_Mouse:	first y-position of the mouse
		mousePosition.i					; in Event_Mouse:	clicked position (#TE_MousePosition_...)
		firstMousePosition.i			; in Event_Mouse:	first clicked position (#TE_MousePosition_...)
		firstSelection.TE_RANGE			; in Event_Mouse:	first selection
		position.TE_POSITION			; in Event_Mouse:	position
		previousPosition.TE_POSITION	; in Event_Mouse:	previous position
		
		selection.TE_RANGE
		previousSelection.TE_RANGE
		
		dragDropMode.i
		dragStart.i
		dragText.s
		dragTextPreview.s
		dragPosition.TE_POSITION
		
		canvasMouseX.i					; mouse Position inside Canvas (dpi aware)
		canvasMouseY.i
		mouseX.i						; mouse Position inside Canvas (unscaled version of canvasMouseX / canvasMouseY)
		mouseY.i
		windowMouseX.i					; mouse Position inside Window
		windowMouseY.i
		desktopMouseX.i					; mouse Position inside Desktop
		desktopMouseY.i
		deltaX.i						; mouse movement
		deltaY.i
		
		needRedraw.i
	EndStructure
	
	Structure TE_CURSOR
		clipBoard.s
		firstPosition.TE_POSITION
		previousPosition.TE_POSITION
		previousSelection.TE_POSITION
		position.TE_POSITION
		selection.TE_POSITION
		
		isVisible.b
		number.i
	EndStructure
	
	Structure TE_SCROLL
		visibleLineNr.i
		charX.i
		scrollTime.i
		scrollDelay.i
		autoScrollV.i				; activated, when the mouse
		autoScrollH.i				; is near the canvas borders
	EndStructure
	
	Structure TE_SCROLLBAR
		gadget.i
		enabled.i
		isHidden.i
		scale.d
	EndStructure
	
	Structure TE_FIND
		wnd_findReplace.i
		cmb_search.i
		txt_search.i
		chk_replace.i
		cmb_replace.i
		frm_0.i
		chk_caseSensitive.i
		chk_wholeWords.i
		chk_insideSelection.i
		chk_noComments.i
		chk_noStrings.i
		chk_regEx.i
		btn_findNext.i
		btn_findPrevious.i
		btn_replace.i
		btn_replaceAll.i
		btn_close.i
		
		text.s
		replace.s
		replaceCount.i
		flags.i
		startPos.TE_POSITION
		endPos.TE_POSITION
		
		regEx.i
		
		isVisible.i
	EndStructure
	
	Structure TE_UNDOENTRY
		action.b
		startPos.TE_POSITION
		endPos.TE_POSITION
		text.s
	EndStructure
	
	Structure TE_UNDO
		List entry.TE_UNDOENTRY()
		
		start.i
		index.i
		clearRedo.i
	EndStructure
	
	Structure TE_SYNTAXHIGHLIGHT
		style.i
		*textline.TE_TEXTLINE
		startCharNr.i
		EndCharNr.i
	EndStructure
	
	Structure TE_TEXTBLOCK
		firstVisibleLineNr.i
		firstLineNr.i
		firstCharNr.i
		lastVisibleLineNr.i
		lastLineNr.i
		lastCharNr.i
		*firstLine.TE_TEXTLINE
		*lastLine.TE_TEXTLINE
	EndStructure
	
	Structure TE_TEXTLINE
		Array style.b(0)
		Array syntaxHighlight.b(0)
		Array token.TE_TOKEN(0)
		
		text.s
		textWidth.d
		
		lineNr.l
		
		tokenCount.l
		
		foldState.b				; #TE_Folding_Folded		start of textblock (folded)
								; #TE_Folding_Unfolded		start of textblock (unfolded)
								; #TE_Folding_End			end of textblock
		foldCount.l
		foldSum.l
		
		indentationBefore.b
		indentationAfter.b
		
		needRedraw.b
		needStyling.b
		
		marker.b
		remark.b
	EndStructure
	
	Structure TE_VIEW
		*editor.TE_STRUCT
		canvas.i
		
		x.i
		y.i
		width.i
		height.i
		zoom.d
		
		pageHeight.i
		pageWidth.i
		
		firstVisibleLineNr.i
		lastVisibleLineNr.i
		
		scroll.TE_SCROLL
		
		scrollBarH.TE_SCROLLBAR
		scrollBarV.TE_SCROLLBAR
		
		*parent.TE_VIEW
		*child.TE_VIEW[2]
	EndStructure
	
	Structure TE_LANGUAGE
		fileName.s
		
		errorTitle.s
		errorRegEx.s
		errorNotFound.s
		
		warningTitle.s
		warningLongText.s
		
		gotoTitle.s
		gotoMessage.s
		
		messageTitleFindReplace.s
		messageNoMoreMatches.s
		messageNoMoreMatchesStart.s
		messageNoMoreMatchesEnd.s
		messageReplaceComplete.s
	EndStructure
	
	Structure TE_REPEATEDSELECTION
		text.s
		textLen.i
		mode.i
		minCharacterCount.i		
	EndStructure
	
	Structure TE_STRUCT
		*view.TE_VIEW
		*currentView.TE_VIEW
		
		List textLine.TE_TEXTLINE()
		List textBlock.TE_TEXTBLOCK()
		List syntaxHighlight.TE_SYNTAXHIGHLIGHT()
		List lineHistory.i()
		
		Map keyWord.TE_KEYWORD()
		Map keyWordLineContinuation.s()
		Map dictionary.s()
		Map syntax.TE_SYNTAX()
		
		Array font.TE_FONT(8)
		Array textStyle.TE_TEXTSTYLE(255)
		
		isActive.b
		
		fontName.s
		
		language.TE_LANGUAGE
		
		lineHeight.i
		
		autoComplete.TE_AUTOCOMPLETE
		parser.TE_PARSER
		
		visibleLineCount.i
		
		window.i
		container.i
		popupMenu.i
		
		maxTextWidth.i
		
		scrollbarWidth.i
		leftBorderOffset.i
		leftBorderSize.i
		topBorderSize.i
		
		cursorState.TE_CURSORSTATE
		List cursor.TE_CURSOR()
		*currentCursor.TE_CURSOR
		*maincursor.TE_CURSOR
		
		undo.TE_UNDO
		redo.TE_UNDO
		
		find.TE_FIND
		
		needScrollUpdate.i
		needFoldUpdate.i
		needDictionaryUpdate.i
		redrawMode.i
		redrawRange.TE_RANGE
		
		highlightSyntax.i
		
		repeatedSelection.TE_REPEATEDSELECTION
		
		regExRepeatedSelection.i
		regExFind.i
		regExDictionary.i
		
		wordWrapMode.i
		wordWrapSize.i
		
		indentationMode.i
		
		useRealTab.i
		tabSize.i
		
		commentChar.s
		uncommentChar.s
		
		newLineText.s
		newLineChar.c
		
		foldChar.c
		
		colors.TE_COLORSCHEME
		
		flags.i
	EndStructure
	
	Structure TE_WINDOW
		*activeEditor.TE_STRUCT
		cursorThread.i
		redrawing.b
	EndStructure
	
	;-
	;- ------------ DECLARE -----------
	;-
	
	Declare Editor_New(window, x, y, width, height, languageFile.s = "")
	Declare Editor_Free(*te.TE_STRUCT)
	Declare Editor_Activate(*te.TE_STRUCT, isActive, activeGadget = #True)
	Declare Editor_Resize(*te.TE_STRUCT, x, y, width, height) 
	
	Declare View_Add(*te.TE_STRUCT, x, y, width, height, *parent.TE_VIEW, *view.TE_VIEW = #Null)
	Declare View_Split(*te.TE_STRUCT, x, y, splitMode = #TE_View_SplitHorizontal)
	Declare View_Unsplit(*te.TE_STRUCT, x, y)
	Declare View_FromMouse(*te.TE_STRUCT, *view.TE_VIEW, x, y)
	Declare View_Resize(*te.TE_STRUCT, *view.TE_VIEW, x, y, width, height)
	Declare View_Clear(*te.TE_STRUCT, *view.TE_VIEW)
	Declare View_Delete(*te.TE_STRUCT, *view.TE_VIEW)
	
	Declare Max(a, b)
	Declare Min(a, b)
	Declare Clamp(value, min, max)
	Declare.s TokenName(*token.TE_TOKEN)
	Declare.s TokenText(*token.TE_TOKEN)
	Declare LineNr_from_VisibleLineNr(*te.TE_STRUCT, visibleLineNr)
	Declare LineNr_to_VisibleLineNr(*te.TE_STRUCT, lineNr)
	Declare BorderSize(*te.TE_STRUCT)
	Declare Position_InsideRange(*pos.TE_POSITION, *range.TE_RANGE, includeBorder = #True)
	Declare Position_Equal(*pos1.TE_POSITION, *pos2.TE_POSITION)
	Declare Position_Changed(*pos1.TE_POSITION, *pos2.TE_POSITION)
	
	Declare.s Text_Get(*te.TE_STRUCT, startLineNr, startCharNr, endLineNr, endCharNr)
	
	Declare Undo_Start(*te.TE_STRUCT, *undo.TE_UNDO)
	Declare Undo_Add(*te.TE_STRUCT, *undo.TE_UNDO, action, startLineNr = 0, startCharNr = 0, endLineNr = 0, endCharNr = 0, text.s = "")
	Declare Undo_Do(*te.TE_STRUCT, *undo.TE_UNDO, *redo.TE_UNDO)
	Declare Undo_Update(*te.TE_STRUCT)
	Declare Undo_Clear(*undo.TE_UNDO)
	
	Declare Syntax_Add(*te.TE_STRUCT, text.s, flags = #TE_Parser_Multiline)
	
	Declare Style_Textline(*te.TE_STRUCT, *textLine.TE_TEXTLINE, styleFlags = 0, *undo.TE_UNDO = #Null)
	Declare Style_LoadFont(*te.TE_STRUCT, *font.TE_FONT, fontName.s, fontSize, fontStyle = 0)
	Declare Style_SetFont(*te.TE_STRUCT, fontName.s, fontSize, fontStyle = 0)
	Declare Style_Set(*te.TE_STRUCT, styleNr, fontNr, color, bColor = #TE_Ignore, uColor = #TE_Ignore)
	Declare Style_SetDefaultStyle(*te.TE_STRUCT)
	Declare Style_FromCharNr(*textLine.TE_TEXTLINE, charNr, scanWholeLine = #False)
	
	Declare Parser_Initialize(*parser.TE_PARSER)
	Declare Parser_Clear(*parser.TE_PARSER)
	Declare Parser_TokenAtCharNr(*te.TE_STRUCT, *textLine.TE_TEXTLINE, charNr, testBounds = #False, startIndex = 1)
	Declare Parser_NextToken(*te.TE_STRUCT, direction, flags = #TE_Parser_SkipWhiteSpace)
	
	Declare KeyWord_Add(*te.TE_STRUCT, key.s, style = #TE_Ignore, caseCorrection = #TE_Ignore)
	Declare KeyWord_LineContinuation(*te.TE_STRUCT, key.s)
	Declare KeyWord_Folding(*te.TE_STRUCT, key.s, foldState)
	Declare KeyWord_Indentation(*te.TE_STRUCT, key.s, indentationBefore, indentationAfter)
	
	Declare Folding_Update(*te.TE_STRUCT, firstLine, lastLine)
	Declare Folding_UnfoldTextline(*te.TE_STRUCT, lineNr, updateFolding = #True)
	Declare Folding_GetTextBlock(*te.TE_STRUCT, lineNr, foldstate = 0)
	
	Declare.s Indentation_Clear(*textLine.TE_TEXTLINE)
	
	Declare Textline_Add(*te.TE_STRUCT)
	Declare Textline_Insert(*te.TE_STRUCT)
	Declare Textline_Delete(*te.TE_STRUCT)
	Declare Textline_FromLine(*te.TE_STRUCT, lineNr)
	Declare Textline_FromVisibleLineNr(*te.TE_STRUCT, visibleLineNr)
	Declare Textline_TopLine(*te.TE_STRUCT)
	Declare Textline_BottomLine(*te.TE_STRUCT)
	Declare Textline_AddChar(*te.TE_STRUCT, *cursor.TE_CURSOR, c.c, overwrite, styleFlags = #TE_Styling_All, *undo.TE_UNDO = #Null)
	Declare Textline_AddText(*te.TE_STRUCT, *cursor.TE_CURSOR, *c.Character, textLength, styleFlags = #TE_Styling_All, *undo.TE_UNDO = #Null)
	Declare Textline_ChangeText(*te.TE_STRUCT, *textline.TE_TEXTLINE, charNr, newText.s, *undo.TE_UNDO)
	Declare Textline_SetText(*te.TE_STRUCT, *textLine.TE_TEXTLINE, text.s, styleFlags = #TE_Styling_All, *undo.TE_UNDO = #Null)
	Declare Textline_AddRemark(*te.TE_STRUCT, lineNr, type , text.s, *undo.TE_UNDO)
	Declare Textline_DeleteRemark(*te.TE_STRUCT, lineNr, *undo.TE_UNDO)
	Declare TextLine_IsEmpty(*textline.TE_TEXTLINE)
	Declare Textline_LineNr(*te.TE_STRUCT, *textline.TE_TEXTLINE)
	Declare Textline_LineNrFromScreenPos(*te.TE_STRUCT, *view.TE_VIEW, screenY)
	Declare Textline_Length(*textLine.TE_TEXTLINE)
	Declare Textline_LastCharNr(*te.TE_STRUCT, lineNr)
	Declare Textline_NextTabSize(*te, *textline.TE_TEXTLINE, charNr)
	Declare Textline_Width(*te.TE_STRUCT, *textLine.TE_TEXTLINE)
	Declare Textline_CharNrFromScreenPos(*te.TE_STRUCT, *textLine.TE_TEXTLINE, screenX)
	Declare Textline_ColumnFromCharNr(*te.TE_STRUCT, *view.TE_VIEW, *textLine.TE_TEXTLINE, charNr)
	Declare Textline_CharNrToScreenPos(*te.TE_STRUCT, *textLine.TE_TEXTLINE, charNr)
	Declare Textline_FindText(*textline.TE_TEXTLINE, find.s, *result.TE_RANGE, ignoreWhiteSpace = #False)
	Declare Textline_HasLineContinuation(*te.TE_STRUCT, *textline.TE_TEXTLINE)
	
	Declare SyntaxHighlight_Clear(*te.TE_STRUCT)
	Declare SyntaxHighlight_Update(*te.TE_STRUCT)
	
	Declare Selection_Get(*cursor.TE_CURSOR, *range.TE_RANGE)
	Declare Selection_Add(*range.TE_RANGE, lineNr, charNr)
	Declare Selection_SetRange(*te.TE_STRUCT, *cursor.TE_CURSOR, lineNr, charNr, highLight = #True, checkOverlap = #True)
	Declare Selection_SelectAll(*te.TE_STRUCT)
	Declare Selection_Clear(*te.TE_STRUCT, *cursor.TE_CURSOR)
	Declare Selection_ClearAll(*te.TE_STRUCT, deleteCursors = #False)
	Declare Selection_Delete(*te.TE_STRUCT, *cursor.TE_CURSOR, *undo.TE_UNDO = #Null)
	Declare.s Selection_Text(*te.TE_STRUCT, delimiter.s = "")
	Declare Selection_Unfold(*te.TE_STRUCT, startLine, endLine)
	Declare Selection_IsAnythingSelected(*te.TE_STRUCT)
	Declare Selection_Overlap(*sel1.TE_RANGE, *sel2.TE_RANGE)
	Declare Selection_CharCount(*te.TE_STRUCT, *cursor.TE_CURSOR)
	Declare Selection_WholeWord(*te.TE_STRUCT, *cursor.TE_CURSOR, lineNr, charNr, *result.TE_RANGE = #Null)
	
	Declare RepeatedSelection_Update(*te.TE_STRUCT, startLine, startCharNr, endLine, endCharNr)
	Declare RepeatedSelection_Clear(*te.TE_STRUCT)
	
	Declare Cursor_Add(*te.TE_STRUCT, lineNr, charNr, checkOverlap = #True, startSelection = #True)
	Declare Cursor_Delete(*te.TE_STRUCT, *cursor.TE_CURSOR)
	Declare Cursor_Update(*te.TE_STRUCT, *cursor.TE_CURSOR, updateLastX, *undo.TE_UNDO = #Null)
	Declare Cursor_DeleteOverlapping(*te.TE_STRUCT, *cursor.TE_CURSOR, joinSelections = #False)
	Declare Cursor_Clear(*te.TE_STRUCT, *maincursor.TE_CURSOR)
	Declare Cursor_Sort(*te.TE_STRUCT, sortOrder = #PB_Sort_Ascending)
	Declare Cursor_Move(*te.TE_STRUCT, *cursor.TE_CURSOR, dirY, dirX, *undo.TE_UNDO = #Null)
	Declare Cursor_MoveMulti(*te.TE_STRUCT, *cursor.TE_CURSOR, previousLineNr, dirY, dirX)
	Declare Cursor_Position(*te.TE_STRUCT, *cursor.TE_CURSOR, lineNr, charNr, ensureVisible = #True, updateLastX = #True, *undo.TE_UNDO = #Null)
	Declare Cursor_HasSelection(*cursor.TE_CURSOR)
	Declare Cursor_GetScreenPos(*te.TE_STRUCT, *view.TE_VIEW, x, y, *result.TE_POSITION)
	Declare Cursor_FromScreenPos(*te.TE_STRUCT, *view.TE_VIEW, *cursor.TE_CURSOR, x, y, addCursor = #False)
	Declare Cursor_Thread(*window.TE_WINDOW)
	; 	Declare Cursor_InsideComment(*te.TE_STRUCT, *cursor.TE_CURSOR)
	
	Declare Scroll_Line(*te.TE_STRUCT, *view.TE_VIEW, *cursor.TE_CURSOR, visibleLineNr, keepCursor = #True, updateGadget = #True)
	Declare Scroll_Char(*te.TE_STRUCT, *view.TE_VIEW, charX)
	Declare Scroll_Update(*te.TE_STRUCT, *view.TE_VIEW, *cursor.TE_CURSOR, previousVisibleLineNr, previousCharNr, updateNeeded = #True)
	Declare Scroll_UpdateAllViews(*te.TE_STRUCT, *view.TE_VIEW, *currentView.TE_VIEW, *cursor.TE_CURSOR)
	Declare Scroll_HideScrollBarH(*te.TE_STRUCT, *view.TE_VIEW, isHidden)
	Declare Scroll_HideScrollBarV(*te.TE_STRUCT, *view.TE_VIEW, isHidden)
	
	; 		Declare Draw_Thread(*te.TE_STRUCT)
	Declare Draw(*te.TE_STRUCT, *view.TE_VIEW, cursorBlinkState = -1, redrawMode = 0)
	Declare.d Draw_Textline(*te.TE_STRUCT, *view.TE_VIEW, *textLine.TE_TEXTLINE, lineNr, x.d, y.d, backgroundColor, Array selection.a(1))
	
	Declare Remark_Clear(*te.TE_STRUCT, *selection.TE_RANGE = #Null)
	
	Declare Marker_Add(*te.TE_STRUCT, *textline.TE_TEXTLINE, style)
	Declare Marker_ClearAll(*te.TE_STRUCT)
	
	Declare Find_Next(*te.TE_STRUCT, lineNr, charNr, endLineNr, endCharNr, flags)
	Declare Find_Flags(*te.TE_STRUCT)
	Declare Find_Close(*te.TE_STRUCT)
	Declare Find_SetSelectionCheckbox(*te.TE_STRUCT)
	
	Declare Autocomplete_Hide(*te.TE_STRUCT)
	Declare Autocomplete_UpdateDictonary(*te.TE_STRUCT, startLineNr = 0, endLineNr = 0)
	Declare Autocomplete_Scroll(*te.TE_STRUCT, direction, scrollPosition.d = 0)
	
	Declare Remark_IsSelected(*te.TE_STRUCT, lineNr, endLineNr)
	
	Declare Event_Gadget()
	Declare Event_Keyboard(*te.TE_STRUCT, *view.TE_VIEW, eventType)
	Declare Event_Mouse(*te.TE_STRUCT, *view.TE_VIEW, event_type)
	Declare Event_MouseWheel(*te.TE_STRUCT, *view.TE_VIEW, eventType)
	Declare Event_ScrollBar()
	Declare Event_Timer()
	Declare Event_FindReplace()
	Declare Event_Menu()
	Declare Event_Cursor()
	Declare Event_Redraw()
	
	Declare Event_Drop()
	;Declare Event_DropCallback(TargetHandle, State, Format, Action, x, y)
	
	Declare Tokenizer_All(*te.TE_STRUCT)
	Declare Tokenizer_Textline(*te, *textline)
	
	Declare Settings_OpenXml(*te.TE_STRUCT, fileName.s)
	Declare Styling_OpenXml(*te.TE_STRUCT, fileName.s, clearKeywords = #True)
	
	Declare.s Debug_TokenAtCursor(*te.TE_STRUCT)
	
	Macro ProcedureReturnIf(cond_, retVal_ = 0)
		If cond_
			ProcedureReturn retVal_
		EndIf
	EndMacro
	
	Macro PreferenceString(key_, defaultValue_)
		UnescapeString(ReadPreferenceString(key_, defaultValue_))
	EndMacro
	
	Macro SetFlag(te_, flag_, val_)
		If (val_)
			te_\flags | (flag_)
		Else
			te_\flags & ~(flag_)
		EndIf
	EndMacro
	
	Macro GetFlag(te_, flag_)
		Bool(te_\flags & (flag_))
	EndMacro
EndDeclareModule

Module _PBEdit_
	EnableExplicit
	
	Global _PBEdit_Mutex.i = CreateMutex()
	Global _PBEdit_Window_.TE_WINDOW
	
	Global DEBUGDRAWCOUNTER, DEBUGDRAWCOLOR
	
	Procedure Debug_Position(text.s, *position.TE_POSITION)
		If *position
			Debug text + #TAB$ + "lineNr: " + Str(*position\lineNr) + "   charNr: " + Str(*position\charNr)
		EndIf
	EndProcedure
	
	Procedure Debug_Range(text.s, *range.TE_RANGE)
		If *range
			Debug text + #TAB$ + "pos1: " + Str(*range\pos1\lineNr) + "/" + Str(*range\pos1\charNr) + " - pos2: " + Str(*range\pos2\lineNr) + "/" + Str(*range\pos2\charNr)
		EndIf
	EndProcedure
	
	Procedure.s Debug_TokenAtCursor(*te.TE_STRUCT)
		ProcedureReturnIf((*te = #Null) Or (*te\currentCursor = #Null), "")
		If Parser_TokenAtCharNr(*te, *te\currentCursor\position\textline, *te\currentCursor\position\charNr)
			ProcedureReturn "Token: " + TokenEnumName(*te\parser\token\type) + " Style: " + StyleEnumName(*te\currentCursor\position\textLine\style(*te\parser\token\charNr))
		EndIf
	EndProcedure
	
	;-
	;- ------------ INITIALIZATION -----------
	;-
	
	Procedure Language_Initialize(*te.TE_STRUCT, languageFile.s = "")
		ProcedureReturnIf(*te = #Null)
		
		If languageFile = ""
			languageFile = ".\lang\PBEdit_EN.cfg"
		EndIf
		
		*te\language\fileName = languageFile
		
		OpenPreferences(languageFile)
		PreferenceGroup("Messages")
		*te\language\warningTitle = PreferenceString("WarningTitle", "Warning")
		*te\language\warningLongText = PreferenceString("WarningLongText", "Very long text (%N1 characters) at %N2 locations.\n Insert anyway ?")
		
		*te\language\errorTitle = PreferenceString("ErrorTitle", "Error")
		*te\language\errorRegEx = PreferenceString("ErrorRegEx", "Error in Regular Expression")
		
		*te\language\errorNotFound = PreferenceString("ErrorNotFound", "%N1\nnot found")
		
		*te\language\gotoTitle = PreferenceString("GotoTitle", "Goto...")
		*te\language\gotoMessage = PreferenceString("GotoMessage", "Line number")
		
		*te\language\messageTitleFindReplace = PreferenceString("MessageTitleFindReplace", "Find/Replace")
		*te\language\messageNoMoreMatches = PreferenceString("MessageNoMoreMatches", "No more matches found.")
		*te\language\messageNoMoreMatchesEnd = PreferenceString("MessageNoMoreMatchesEnd", "No more matches found.\nDo you want to search from the end of the file?")
		*te\language\messageNoMoreMatchesStart = PreferenceString("MessageNoMoreMatchesStart", "No more matches found.\nDo you want to search from the start of the file?")
		*te\language\messageReplaceComplete = PreferenceString("MessageReplaceComplete", "Find/Replace complete.\n%N1 matches found.")
		ClosePreferences()
	EndProcedure
	
	;-
	
	Procedure Editor_New_FindWindow(*te.TE_STRUCT)
		ProcedureReturnIf(*te = #Null)
		
		OpenPreferences(*te\language\fileName)
		PreferenceGroup("FindReplace")
		
		With *te\find
			\wnd_findReplace = OpenWindow(#PB_Any, 0, 0, 545, 195, PreferenceString("wnd_findReplace", "Find/Replace"), #PB_Window_SystemMenu | #PB_Window_Invisible, WindowID(*te\window))
			\cmb_search = ComboBoxGadget(#PB_Any, 150, 10, 380, 20, #PB_ComboBox_Editable)
			\txt_search = TextGadget(#PB_Any, 10, 10, 130, 20, PreferenceString("txt_search", "Search for") + ":", #PB_Text_Right)
			\chk_replace = CheckBoxGadget(#PB_Any, 10, 40, 130, 20, PreferenceString("chk_replace", "Replace with") + ":")
			\cmb_replace = ComboBoxGadget(#PB_Any, 150, 40, 380, 20, #PB_ComboBox_Editable)
			\frm_0 = FrameGadget(#PB_Any, 10, 75, 520, 75, "", #PB_Frame_Single)
			\chk_caseSensitive = CheckBoxGadget(#PB_Any, 20, 85, 180, 20, PreferenceString("chk_caseSensitive", "Case Sensitive"))
			\chk_wholeWords = CheckBoxGadget(#PB_Any, 20, 105, 180, 20, PreferenceString("chk_wholeWords", "Whole Words only"))
			\chk_insideSelection = CheckBoxGadget(#PB_Any, 20, 125, 180, 20, PreferenceString("chk_insideSelection", "Search inside Selection only"))
			\chk_noComments = CheckBoxGadget(#PB_Any, 280, 85, 180, 20, PreferenceString("chk_noComments", "Don't search in Comments"))
			\chk_noStrings = CheckBoxGadget(#PB_Any, 280, 105, 180, 20, PreferenceString("chk_noStrings", "Don't search in Strings"))
			\chk_regEx = CheckBoxGadget(#PB_Any, 280, 125, 180, 20, PreferenceString("chk_regEx", "Regular Expression"))
			\btn_findNext = ButtonGadget(#PB_Any, 10, 160, 80, 25, PreferenceString("btn_findNext", "Find Next"))
			\btn_findPrevious = ButtonGadget(#PB_Any, 115, 160, 100, 25, PreferenceString("btn_findPrevious", "Find Previous"))
			\btn_replace = ButtonGadget(#PB_Any, 245, 160, 70, 25, PreferenceString("btn_replace", "Replace"))
			\btn_replaceAll = ButtonGadget(#PB_Any, 340, 160, 110, 25, PreferenceString("btn_replaceAll", "Replace All"))
			\btn_close = ButtonGadget(#PB_Any, 455, 160, 80, 25, PreferenceString("btn_close", "Close"))
			\isVisible = #False
			
			RemoveKeyboardShortcut(\wnd_findReplace, #PB_Shortcut_All)
			AddKeyboardShortcut(\wnd_findReplace, #PB_Shortcut_Return, #TE_Menu_ReturnKey)
			AddKeyboardShortcut(\wnd_findReplace, #PB_Shortcut_Escape, #TE_Menu_EscapeKey)
			AddKeyboardShortcut(\wnd_findReplace, #PB_Shortcut_F3, #TE_Menu_F3Key)
			AddKeyboardShortcut(\wnd_findReplace, #PB_Shortcut_Shift | #PB_Shortcut_F3, #TE_Menu_ShiftF3Key)
			
			SetWindowData(\wnd_findReplace, *te)
			
			DisableGadget(\cmb_replace, 1)
			DisableGadget(\btn_replace, 1)
			DisableGadget(\btn_replaceAll, 1)
			DisableGadget(\chk_insideSelection, 1)
			
			BindEvent(#PB_Event_CloseWindow, @Event_FindReplace(), \wnd_findReplace)
			BindEvent(#PB_Event_Menu, @Event_FindReplace(), \wnd_findReplace, #PB_All, #PB_All)
			BindEvent(#PB_Event_Gadget, @Event_FindReplace(), \wnd_findReplace)
		EndWith
		ClosePreferences()
	EndProcedure
	
	Procedure Editor_New_PopupMenu(*te.TE_STRUCT)
		ProcedureReturnIf(*te = #Null)
		
		Protected separator.s = "\t\t\t\t\t"
		
		*te\popupMenu = CreatePopupImageMenu(#PB_Any)
		If *te\popupMenu
			OpenPreferences(*te\language\fileName)
			PreferenceGroup("PopupMenu")
			
			MenuItem(#TE_Menu_Cut, PreferenceString("Cut", "Cut" + separator + "Ctrl+X"))
			MenuItem(#TE_Menu_Copy, PreferenceString("Copy", "Copy" + separator + "Ctrl+C"))
			MenuItem(#TE_Menu_Paste, PreferenceString("Paste", "Paste" + separator + "Ctrl+V"))
			MenuBar()
			MenuItem(#TE_Menu_InsertComment, PreferenceString("InsertComments", "Insert comments" + separator + "Ctrl+B"))
			MenuItem(#TE_Menu_RemoveComment, PreferenceString("RemoveComments", "Remove comments" + separator + "Ctrl+Shift+B"))
			MenuItem(#TE_Menu_FormatIndentation, PreferenceString("FormatIndentation", "Format indentation" + separator + "Ctrl+I"))
			MenuBar()
			MenuItem(#TE_Menu_ToggleFold, PreferenceString("ToggleFold", "Toggle current fold" + separator + "F4"))
			MenuItem(#TE_Menu_ToggleAllFolds, PreferenceString("ToggleAllFolds", "Toggle all folds" + separator + "Ctrl+F4"))
			MenuBar()
			OpenSubMenu( PreferenceString("SplitView", "Split View"))
			MenuItem(#TE_Menu_SplitViewHorizontal, PreferenceString("Horizontal", "Horizontal"))
			MenuItem(#TE_Menu_SplitViewVertical, PreferenceString("Vertical", "Vertical"))
			CloseSubMenu()
			MenuItem(#TE_Menu_UnsplitView, PreferenceString("UnsplitView", "Unsplit View"))
			MenuBar()
			MenuItem(#TE_Menu_Beautify, PreferenceString("Beautify", "Beautify Selection" + separator + "Ctrl+Alt+B"))
			MenuBar()
			MenuItem(#TE_Menu_SelectAll, PreferenceString("Select All", "Select All" + separator + "Ctrl+A"))
			
			BindEvent(#PB_Event_Menu, @Event_Menu())
			ClosePreferences()
		EndIf
	EndProcedure
	
	Procedure Editor_New(window, x, y, width, height, languageFile.s = "")
		ProcedureReturnIf(IsWindow(window) = 0)
		
		Protected *te.TE_STRUCT = AllocateStructure(TE_STRUCT)
		ProcedureReturnIf(*te = #Null)
		
		InitializeStructure(*te, TE_STRUCT)
		
		Parser_Initialize(*te\parser)
		Language_Initialize(*te, languageFile)
		
		*te\window = window
		
		SetFlag(*te, #TE_EnableUndo, 1)
		SetFlag(*te, #TE_EnableScrollBarHorizontal, 1)
		SetFlag(*te, #TE_EnableScrollBarVertical, 1)
		SetFlag(*te, #TE_EnableZooming, 1)
		SetFlag(*te, #TE_EnableStyling, 0)
		SetFlag(*te, #TE_EnableLineNumbers, 0)
		SetFlag(*te, #TE_EnableShowCurrentLine, 0)
		SetFlag(*te, #TE_EnableFolding, 0)
		SetFlag(*te, #TE_EnableIndentation, 0)
		SetFlag(*te, #TE_EnableSelection, 1)
		SetFlag(*te, #TE_EnableCaseCorrection, 0)
		SetFlag(*te, #TE_EnableShowWhiteSpace, 0)
		SetFlag(*te, #TE_EnableIndentationLines, 0)
		SetFlag(*te, #TE_EnableHorizontalFoldLines, 0)
		SetFlag(*te, #TE_EnableAutoComplete, 0)
		SetFlag(*te, #TE_EnableAutoClosingBracket, 0)
		SetFlag(*te, #TE_EnableAutoClosingKeyword, 0)
		SetFlag(*te, #TE_EnableDictionary, 0)
		SetFlag(*te, #TE_EnableSyntaxHighlight, 0)
		SetFlag(*te, #TE_EnableBeautify, 0)
		SetFlag(*te, #TE_EnableMultiCursor, 0)
		SetFlag(*te, #TE_EnableSplitScreen, 0)
		SetFlag(*te, #TE_EnableRepeatedSelection, 0)
		SetFlag(*te, #TE_EnableSelectPastedText, 0)
		SetFlag(*te, #TE_EnableWordWrap, 0)
		SetFlag(*te, #TE_EnableReadOnly, 0)
		SetFlag(*te, #TE_EnableAlwaysShowSelection, 0)
		
		*te\repeatedSelection\mode = #TE_RepeatedSelection_NoCase | #TE_RepeatedSelection_WholeWord
		*te\repeatedSelection\minCharacterCount = 3
		*te\repeatedSelection\text = ""
		*te\repeatedSelection\textLen = 0
		
		*te\wordWrapMode = #TE_WordWrap_None
		*te\indentationMode = #TE_Indentation_None
		*te\useRealTab = #True
		*te\tabSize = 4
		
		*te\cursorState\clickSpeed = 500
		*te\cursorState\blinkDelay = 500
		*te\cursorState\firstClickTime = ElapsedMilliseconds() - 1000
		*te\cursorState\compareMode = #PB_String_NoCase; #PB_String_CaseSensitive
		
		*te\autoComplete\maxRows = 10
		*te\autoComplete\minCharacterCount = 3
		*te\autoComplete\scrollBarWidth = 10
		*te\autoComplete\mode = #TE_Autocomplete_FindAtBegind
		
		*te\fontName = "Consolas"
		*te\lineHeight = 11
		*te\wordWrapSize = 0
		*te\scrollbarWidth = 15
		*te\topBorderSize = 0
		*te\leftBorderSize = 5
		*te\leftBorderOffset = BorderSize(*te)
		*te\newLineChar = #LF
		*te\newLineText = Chr(*te\newLineChar)
		*te\foldChar = 1
		
		*te\regExDictionary = CreateRegularExpression(#PB_Any, "[#*]?\w+[\d+]?[$]?") ; match [*/#]text[number][$]
		
		With *te\colors
			\defaultText = RGBA( 0, 0, 0, 255)
			\selectedText = RGBA(255, 255, 255, 255)
			\cursor = RGBA( 0, 0, 0, 255)
			\inactiveBackground = RGBA(128, 128, 128, 255)
			\currentBackground = RGBA(255, 255, 255, 255)
			\selectionBackground = RGBA( 0, 120, 215, 255)
			\currentLine = RGBA(220, 220, 220, 255)
			\currentLineBackground = RGBA(220, 220, 220, 255)
			\currentLineBorder = RGBA(240, 240, 240, 255)
			\inactiveLineBackground = RGBA( 64, 64, 64, 255)
			\indentationGuides = RGBA( 64, 64, 64, 255)
			\horizontalFoldLines = RGBA( 50, 50, 50, 255)
			\lineNr = RGBA( 32, 32, 32, 255)
			\currentLineNr = RGBA(128, 128, 128, 255)
			\lineNrBackground = RGBA(220, 220, 220, 255)
			\foldIcon = RGBA( 0, 0, 0, 255)
			\foldIconBorder = RGBA( 0, 0, 0, 255)
			\foldIconBackground = RGBA(255, 255, 255, 255)
		EndWith
		
		RemoveKeyboardShortcut(*te\window, #PB_Shortcut_All)
		
		BindEvent(#PB_Event_Timer, @Event_Timer(), window)
		BindEvent(#TE_Event_Redraw, @Event_Redraw())
		
		Editor_New_FindWindow(*te)
		Editor_New_PopupMenu(*te)
		
		Style_SetFont(*te, *te\fontName, *te\lineHeight)
		Style_SetDefaultStyle(*te)
		
		UseGadgetList(WindowID(window))
		*te\container = ContainerGadget(#PB_Any, x, y, width, height, #PB_Container_BorderLess)
		If IsGadget(*te\container) = 0
			Editor_Free(*te)
			ProcedureReturn #Null
		EndIf
		CloseGadgetList()
		
		BindEvent(#TE_Event_CursorBlink, @Event_Cursor())
		
		*te\view = View_Add(*te, 0, 0, width, height, #Null)
		
		*te\currentView = *te\view
		
		If *te\view = #Null
			Editor_Free(*te)
			ProcedureReturn #Null
		EndIf
		
		Protected key.s = Hex(WindowID(window))
		
		Textline_Add(*te)
		Cursor_Add(*te, 1, 1, #False, #False)
		Folding_Update(*te, -1, -1)
		Scroll_Update(*te, *te\view, *te\maincursor, -1, -1)
		Cursor_Position(*te, *te\currentCursor, 1, 1)
		
		Editor_Activate(*te, #True)
		
		ProcedureReturn *te
	EndProcedure
	
	Procedure Editor_Free(*te.TE_STRUCT)
		ProcedureReturnIf(*te = #Null)
		
		LockMutex(_PBEdit_Mutex)
		_PBEdit_Window_\activeEditor = #Null
		UnlockMutex(_PBEdit_Mutex)
		
		WaitThread(_PBEdit_Window_\cursorThread)
		
		If IsWindow(*te\window)
			; 			RemoveKeyboardShortcut(*te\window, #PB_Shortcut_All)
			; 			UnbindEvent(#PB_Event_SizeWindow, @Event_Window(), *te\window)
			; 			UnbindEvent(#PB_Event_MoveWindow, @Event_Window(), *te\window)
			; 			UnbindEvent(#PB_Event_DeactivateWindow, @Event_Window(), *te\window)
			; 			UnbindEvent(#PB_Event_Timer, @Event_Timer(), *te\window)
			; 			RemoveWindowTimer(*te\window, #TE_Timer_CursorBlink)
			
			RemoveWindowTimer(*te\window, #TE_Timer_Scroll)
			
			If IsMenu(*te\popupMenu)
				FreeMenu(*te\popupMenu)
			EndIf
		EndIf
		
		If IsWindow(*te\find\wnd_findReplace)
			CloseWindow(*te\find\wnd_findReplace)
		EndIf
		
		View_Clear(*te, *te\view)
		View_Delete(*te, *te\view)
		
		If IsGadget(*te\container)
			FreeGadget(*te\container)
		EndIf
		
		
		If IsRegularExpression(*te\regExRepeatedSelection)
			FreeRegularExpression(*te\regExRepeatedSelection)
		EndIf
		If IsRegularExpression(*te\regExFind)
			FreeRegularExpression(*te\regExFind)
		EndIf
		
		FreeStructure(*te)
	EndProcedure
	
	Procedure Editor_Activate(*te.TE_STRUCT, isActive, activeGadget = #True)
		ProcedureReturnIf((*te = #Null) Or (IsWindow(*te\window) = 0))
		
		*te\isActive = Bool(isActive)
		
		If *te\isActive = #False
			Autocomplete_Hide(*te.TE_STRUCT)
			; 			*te\cursorState\blinkState = 0
			; 			Draw(*te, *te\view, 1, #TE_Redraw_All)
		EndIf
		
		PushListPosition(*te\cursor())
		ForEach *te\cursor()
			*te\cursor()\isVisible = *te\isActive
		Next
		PopListPosition(*te\cursor())
		
		LockMutex(_PBEdit_Mutex)
		_PBEdit_Window_\activeEditor = *te
		UnlockMutex(_PBEdit_Mutex)
		
		If *te\cursorState\blinkDelay > 0
			If IsThread(_PBEdit_Window_\cursorThread) = 0
				_PBEdit_Window_\cursorThread = CreateThread(@Cursor_Thread(), _PBEdit_Window_)
			EndIf
		Else
			*te\cursorState\blinkState = 0
		EndIf
		
		If activeGadget
			SetActiveGadget(*te\currentView\canvas)
		EndIf
		
		PostEvent(#TE_Event_Redraw, 0, 0, #TE_EventType_RedrawAll, *te\view)
	EndProcedure
	
	Procedure Editor_Resize(*te.TE_STRUCT, x, y, width, height) 
		ProcedureReturnIf((*te = #Null) Or (*te\view = #Null))
		
		Autocomplete_Hide(*te.TE_STRUCT)
		
		If x = #PB_Ignore
			x = GadgetX(*te\container)
		EndIf
		If y = #PB_Ignore
			y = GadgetY(*te\container)
		EndIf
		If width = #PB_Ignore
			width = GadgetWidth(*te\container)
		EndIf
		If height = #PB_Ignore
			height = GadgetHeight(*te\container)
		EndIf
		
		; 			HideGadget(*te\container, 1)
		ResizeGadget(*te\container, x, y, width, height)
		
		View_Resize(*te, *te\view, 0, 0, width, height)
		; 			HideGadget(*te\container, 0)
		
		PostEvent(#TE_Event_Redraw, 0, 0, #TE_EventType_RedrawAll, *te\view)
	EndProcedure
	
	;-
	;- ------------ VIEW -----------
	;-
	
	Procedure View_Add(*te.TE_STRUCT, x, y, width, height, *parent.TE_VIEW, *view.TE_VIEW = #Null)
		ProcedureReturnIf((*te = #Null) Or (width < 1) Or (height < 1))
		
		If *view = #Null
			*view = AllocateStructure(TE_VIEW)
		EndIf
		
		If *view = #Null
			ProcedureReturn #Null
		EndIf
		
		UseGadgetList(WindowID(*te\window))
		
		OpenGadgetList(*te\container)
		*view\canvas = CanvasGadget(#PB_Any, x, y, width, height, #PB_Canvas_Container | #PB_Canvas_Keyboard)
		
		If IsGadget(*view\canvas) = 0
			FreeStructure(*view)
			CloseGadgetList()
			ProcedureReturn #Null
		EndIf
		
		*view\editor = *te
		*view\parent = *parent
		
		*view\x = x
		*view\y = y
		*view\width = width
		*view\height = height
		*view\zoom = 1.0
		
		*view\scroll\visibleLineNr = 1
		*view\scroll\charX = 1
		*view\scroll\scrollDelay = 25
		
		*view\scrollBarV\enabled = GetFlag(*te, #TE_EnableScrollBarVertical)
		
		*view\scrollBarH\enabled = GetFlag(*te, #TE_EnableScrollBarHorizontal)
		*view\scrollBarH\scale = 10
		
		*view\scrollBarV\gadget = ScrollBarGadget(#PB_Any, x + width - *te\scrollbarWidth, y, *te\scrollbarWidth, height, 0, 1, 1, #PB_ScrollBar_Vertical)
		*view\scrollBarH\gadget = ScrollBarGadget(#PB_Any, x, y + height - *te\scrollbarWidth, width, *te\scrollbarWidth, 0, 1, 1)
		*view\scrollBarV\isHidden = #True
		*view\scrollBarH\isHidden = #True
		HideGadget(*view\scrollBarV\gadget, #True)
		HideGadget(*view\scrollBarH\gadget, #True)
		
		CloseGadgetList()
		CloseGadgetList()
		
		SetActiveGadget(*view\canvas)
		
		SetGadgetAttribute(*view\scrollBarV\gadget, #PB_ScrollBar_Minimum, 1)
		SetGadgetAttribute(*view\scrollBarV\gadget, #PB_ScrollBar_Maximum, *view\pageHeight)
		
		SetGadgetData(*view\canvas, *view)
		
		SetGadgetData(*view\scrollBarV\gadget, *view)
		SetGadgetData(*view\scrollBarH\gadget, *view)
		SetGadgetAttribute(*view\canvas, #PB_Canvas_Cursor, #PB_Cursor_IBeam)
		
		EnableGadgetDrop(*view\canvas, #PB_Drop_Text, #PB_Drag_Copy, *view)
		; 		SetDropCallback(@Event_DropCallback())
		
		BindEvent(#PB_Event_GadgetDrop, @Event_Drop())
		BindEvent(#PB_Event_Gadget, @Event_Gadget(), *te\window, *view\canvas)
		BindGadgetEvent(*view\scrollBarH\gadget, @Event_ScrollBar())
		BindGadgetEvent(*view\scrollBarV\gadget, @Event_ScrollBar())
		
		*te\currentView = *view
		*te\redrawMode | #TE_Redraw_All
		
		If *te\currentCursor
			Scroll_Update(*te, *view, *te\currentCursor, *te\currentCursor\position\lineNr, *te\currentCursor\position\charNr)
		EndIf
		
		ProcedureReturn *view
	EndProcedure
	
	Procedure View_Clear(*te.TE_STRUCT, *view.TE_VIEW)
		ProcedureReturnIf((*te = #Null) Or (*view = #Null))
		
		View_Clear(*te, *view\child[0])
		View_Clear(*te, *view\child[1])
		
		If IsGadget(*view\canvas)
			UnbindEvent(#PB_Event_Gadget, @Event_Gadget(), *te\window, *view\canvas)
			
			FreeGadget(*view\canvas)
		EndIf
		
		If IsGadget(*view\scrollBarH\gadget)
			UnbindGadgetEvent(*view\scrollBarH\gadget, @Event_ScrollBar())
			
			FreeGadget(*view\scrollBarH\gadget)
		EndIf
		
		If IsGadget(*view\scrollBarV\gadget)
			UnbindGadgetEvent(*view\scrollBarV\gadget, @Event_ScrollBar())
			
			FreeGadget(*view\scrollBarV\gadget)
		EndIf
		
		*view\canvas = #Null
		*view\scrollBarH\gadget = #Null
		*view\scrollBarV\gadget = #Null
	EndProcedure
	
	Procedure View_Delete(*te.TE_STRUCT, *view.TE_VIEW)
		ProcedureReturnIf((*te = #Null) Or (*view = #Null) Or (*view = *te\view))
		
		View_Clear(*te, *view)
		
		View_Delete(*te, *view\child[0])
		View_Delete(*te, *view\child[1])
		
		FreeStructure(*view)

		ProcedureReturn #True
	EndProcedure
	
	Procedure View_Unsplit(*te.TE_STRUCT, x, y)
		ProcedureReturnIf(*te = #Null)
		
		Protected result = #False
		Protected *parent.TE_VIEW
		
		x = DesktopUnscaledX(x)
		y = DesktopUnscaledY(y)
		
		Protected *view.TE_VIEW = View_FromMouse(*te, *te\view, x, y)
		If *view
			LockMutex(_PBEdit_Mutex)
			
			*te\currentView = *view
			
			If *view\parent
				*parent = *view\parent
				
				View_Delete(*te, *parent\child[0])
				View_Delete(*te, *parent\child[1])
				
				*parent\child[0] = #Null
				*parent\child[1] = #Null
				
				If View_Add(*te, *parent\x, *parent\y, *parent\width, *parent\height, *parent\parent, *parent)
					*te\redrawMode | #TE_Redraw_All
					result = #True
				EndIf
			EndIf
			
			UnlockMutex(_PBEdit_Mutex)
		EndIf
		
		ProcedureReturn result
	EndProcedure
	
	Procedure View_Split(*te.TE_STRUCT, x, y, splitMode = #TE_View_SplitHorizontal)
		ProcedureReturnIf((*te = #Null) Or (GetFlag(*te, #TE_EnableSplitScreen) = 0))
		
		Protected result = #False
		Protected width, height, width2, height2
		Protected splitPosition.d = 0.5
		
		x = DesktopUnscaledX(x)
		y = DesktopUnscaledY(y)
		
		Protected *view.TE_VIEW = View_FromMouse(*te, *te\view, x, y)
		If *view
			If (splitMode = #TE_View_SplitVertical) And (*view\width <= 0)
				ProcedureReturn #False
			ElseIf (splitMode = #TE_View_SplitHorizontal) And (*view\height <= 0)
				ProcedureReturn #False
			EndIf
			
			
			LockMutex(_PBEdit_Mutex)
			
			
			*te\currentView = *view
			
			If splitPosition < 0
				splitPosition = 0
			ElseIf splitPosition > 1
				splitPosition = 1
			EndIf
			
			If splitMode = #TE_View_SplitVertical
				; splitPosition = ((x - *view\x) / *view\width * 1.0)
				
				x = *view\x + (*view\width * splitPosition)
				y = *view\y
				width = *view\width * (1 - splitPosition)
				height = *view\height
				
				width2 = *view\width * splitPosition
				height2 = *view\height
			ElseIf splitMode = #TE_View_SplitHorizontal
				; splitPosition = ((y - *view\y) / *view\height * 1.0)
				
				x = *view\x
				y = *view\y + (*view\height * splitPosition)
				width = *view\width
				height = *view\height * (1 - splitPosition)
				
				width2 = *view\width
				height2 = *view\height * splitPosition
			EndIf
			
			View_Clear(*te, *view)
			
			*view\child[0] = View_Add(*te, x, y, width, height, *view)
			*view\child[1] = View_Add(*te, *view\x, *view\y, width2, height2, *view)
			
			If *view\child[0] And *view\child[1]
				*te\currentView = *view\child[0]
				Editor_Activate(*te, #True)
				
				Draw(*te, *view, -1, #TE_Redraw_All)
				result = #True
			EndIf
			
			
			UnlockMutex(_PBEdit_Mutex)
			
			
		EndIf
		
		ProcedureReturn result
	EndProcedure
	
	Procedure View_Get(*te.TE_STRUCT, *view.TE_VIEW)
		ProcedureReturnIf((*te = #Null) Or (*view = #Null))
		
		If IsGadget(*view\canvas)
			Scroll_Update(*te, *view, *te\currentCursor, *view\firstVisibleLineNr, -1)
			ProcedureReturn #True
		EndIf
		
		View_Get(*te, *view\child[0])
		View_Get(*te, *view\child[1])
	EndProcedure
	
	Procedure View_FromMouse(*te.TE_STRUCT, *view.TE_VIEW, x, y)
		ProcedureReturnIf((*te = #Null) Or (*view = #Null), #Null)
		
		Protected *result.TE_VIEW
		
		If IsGadget(*view\canvas)
			Protected gx = GadgetX(*view\canvas, #PB_Gadget_ScreenCoordinate)
			Protected gy = GadgetY(*view\canvas, #PB_Gadget_ScreenCoordinate)
			
			If (x >= gx) And (x < gx + GadgetWidth(*view\canvas)) And (y >= gy) And (gy + GadgetHeight(*view\canvas))
				;		SetActiveGadget(*view\canvas)
				ProcedureReturn *view
			EndIf
			
		EndIf
		
		*result = View_FromMouse(*te, *view\child[0], x, y)
		If *result
			ProcedureReturn *result
		EndIf
		
		*result = View_FromMouse(*te, *view\child[1], x, y)
		If *result
			ProcedureReturn *result
		EndIf
		
		ProcedureReturn #Null
	EndProcedure
	
	Procedure View_Zoom(*te.TE_STRUCT, *view.TE_VIEW, direction)
		ProcedureReturnIf((*te = #Null) Or (*view = #Null) Or (GetFlag(*te, #TE_EnableZooming) = 0))
		
		Protected oldZoom.d = *view\zoom
		
		If direction = 0
			*view\zoom = 1.0
		ElseIf direction < 0
			*view\zoom / 0.9
		Else
			*view\zoom * 0.9
		EndIf
		
		If *view\zoom < 0.1
			*view\zoom = 0.1
		ElseIf *view\zoom > 2.0
			*view\zoom = 2.0
		EndIf
		
		Autocomplete_Hide(*te.TE_STRUCT)
		Scroll_Update(*te, *view, *te\currentCursor, -1, 1)
		*te\redrawMode | #TE_Redraw_All
		
		If oldZoom = *view\zoom
			ProcedureReturn #False
		Else
			ProcedureReturn #True
		EndIf
	EndProcedure
	
	Procedure View_Resize(*te.TE_STRUCT, *view.TE_VIEW, x, y, width, height)
		ProcedureReturnIf((*te = #Null) Or (*view = #Null))
		
		If *view\width
			Protected scaleX.d = (width * 1.0) / *view\width
		EndIf
		
		If *view\height
			Protected scaleY.d = (height * 1.0) / *view\height
		EndIf
		
		If x = #PB_Ignore
			x = *view\x
		EndIf
		
		If y = #PB_Ignore
			y = *view\y
		EndIf
		
		If width = #PB_Ignore
			width = *view\width
		EndIf
		
		If height = #PB_Ignore
			height = *view\height
		EndIf
		
		If #PB_Compiler_OS <> #PB_OS_Windows
			height - *te\scrollbarWidth
		EndIf
		
		*view\x = x
		*view\y = y
		*view\width = width
		*view\height = height
		
		If IsGadget(*view\canvas)
			Scroll_HideScrollBarH(*te, *view, #True)
			Scroll_HideScrollBarV(*te, *view, #True)
			
			ResizeGadget(*view\canvas, *view\x, *view\y, *view\width, *view\height)
			
			; fill the canvas with background color (for a little less flickering)
			If StartDrawing(CanvasOutput(*view\canvas))
				Box(0, 0, OutputWidth(), OutputHeight(), *te\colors\currentBackground)
				StopDrawing()
			EndIf
			
			Scroll_Update(*te, *view, *te\currentCursor, *view\scroll\visibleLineNr, *view\scroll\charX)
		EndIf
		
		If *view\child[0]
			View_Resize(*te, *view\child[0], *view\child[0]\x * scaleX, *view\child[0]\y * scaleY, *view\child[0]\width * scaleX, *view\child[0]\height * scaleY)
		EndIf
		If *view\child[1]
			View_Resize(*te, *view\child[1], *view\child[1]\x * scaleX, *view\child[1]\y * scaleY, *view\child[1]\width * scaleX, *view\child[1]\height * scaleY)
		EndIf
	EndProcedure
	
	Procedure View_Next(*te.TE_STRUCT, *view.TE_VIEW, direction, *found.Integer)
		ProcedureReturnIf((*te = #Null) Or (*view = #Null) Or (*found = #Null))
		ProcedureReturnIf(*found\i = 1, 1)
		
		If (*found\i = 0) And (*view = *te\currentView)
			*found\i = -1
		ElseIf (*found\i = -1) And IsGadget(*view\canvas)
			*found\i = 1
			*te\currentView = *view
			SetActiveGadget(*view\canvas)
		EndIf
		
		If direction > 0
			View_Next(*te, *view\child[1], direction, *found)
			View_Next(*te, *view\child[0], direction, *found)
		Else
			View_Next(*te, *view\child[0], direction, *found)
			View_Next(*te, *view\child[1], direction, *found)
		EndIf
		
		ProcedureReturn *found\i
	EndProcedure
	
	;-
	;- ------------ FUNCTIONS -----------
	;-
	
	Procedure Max(a, b)
		If a > b
			ProcedureReturn a
		EndIf
		ProcedureReturn b
	EndProcedure
	
	Procedure Min(a, b)
		If a < b
			ProcedureReturn a
		EndIf
		ProcedureReturn b
	EndProcedure
	
	Procedure Clamp(value, min, max)
		If value < min
			value = min
		EndIf
		If value > max
			value = max
		EndIf
		ProcedureReturn value
	EndProcedure
	
	Procedure TokenType(*parser.TE_PARSER, c.c)
		ProcedureReturnIf((*parser = #Null) Or (c < 0) Or (c > #TE_CharRange))
		
		ProcedureReturn *parser\tokenType(c)
	EndProcedure
	
	Procedure.s TokenName(*token.TE_TOKEN)
		ProcedureReturnIf(*token = #Null, "")
		
		ProcedureReturn TokenEnumName(*token\type)
	EndProcedure
	
	Procedure LineNr_from_VisibleLineNr(*te.TE_STRUCT, visibleLineNr)
		ProcedureReturnIf((*te = #Null) Or (ListSize(*te\textLine()) = 0))
		
		Protected lineNr = visibleLineNr
		Protected *textBlock.TE_TEXTBLOCK
		
		ForEach *te\textBlock()
			If *te\textBlock()\firstVisibleLineNr >= visibleLineNr
				Break
			Else
				If (*textBlock = #Null) Or ((*textBlock\firstLine\foldState <> #TE_Folding_Folded) Or (*te\textBlock()\firstLineNr >= *textBlock\lastLineNr))
					*textBlock = *te\textBlock()
				EndIf
			EndIf
		Next
		
		If *textBlock
			If *textBlock\firstLine\foldState = #TE_Folding_Folded
				lineNr = *textBlock\lastLineNr + (visibleLineNr - *textBlock\firstVisibleLineNr)
			Else
				lineNr = *textBlock\firstLineNr + (visibleLineNr - *textBlock\firstVisibleLineNr)
			EndIf
		EndIf
		
		ProcedureReturn Clamp(lineNr, 1, ListSize(*te\textLine()))
	EndProcedure
	
	Procedure LineNr_to_VisibleLineNr(*te.TE_STRUCT, lineNr)
		ProcedureReturnIf((*te = #Null) Or (ListSize(*te\textLine()) = 0))
		
		Protected visibleLineNr = lineNr
		Protected *textBlock.TE_TEXTBLOCK
		
		ForEach *te\textBlock()
			If *te\textBlock()\firstLineNr >= lineNr
				Break
			Else
				If (*textBlock = #Null) Or ( (*textBlock\firstLine\foldState <> #TE_Folding_Folded) Or (*te\textBlock()\firstLineNr >= *textBlock\lastLineNr))
					*textBlock = *te\textBlock()
				EndIf
			EndIf
		Next
		
		If *textBlock
			If *textBlock\firstLine\foldState = #TE_Folding_Folded
				visibleLineNr = *textBlock\lastVisibleLineNr + (lineNr - *textBlock\lastLineNr)
			Else
				visibleLineNr = *textBlock\firstVisibleLineNr + (lineNr - *textBlock\firstLineNr)
			EndIf
		EndIf
		
		ProcedureReturn Clamp(visibleLineNr, 1, *te\visibleLineCount)
	EndProcedure
	
	Procedure FoldiconSize(*te.TE_STRUCT)
		ProcedureReturnIf(*te = #Null)
		
		ProcedureReturn Int(*te\lineHeight * 0.35) << 1
	EndProcedure
	
	Procedure BorderSize(*te.TE_STRUCT)
		ProcedureReturnIf(*te = #Null)
		
		Protected size = *te\leftBorderSize
		Protected textLine.TE_TEXTLINE
		Protected nrLines
		
		If GetFlag(*te,#TE_EnableFolding)
			size + FoldiconSize(*te) + 8
		EndIf
		
		If GetFlag(*te, #TE_EnableLineNumbers)
			nrLines = max(1, ListSize(*te\textLine()))
			textLine\text = RSet(Str(nrLines), Int(Log10(ListSize(*te\textLine())) + 1))
			size + Textline_Width(*te, textLine)
		EndIf
		
		ProcedureReturn size
	EndProcedure
	
	Procedure Position_InsideRange(*pos.TE_POSITION, *range.TE_RANGE, includeBorder = #True)
		; test if lineNr/charNr is inside given range
		;
		; return value:
		;  0	-		not inside range
		; -1	-		position near range start
		;  1	-		position near range end
		
		ProcedureReturnIf((*pos = #Null) Or (*range = #Null))
		ProcedureReturnIf((*pos\lineNr < *range\pos1\lineNr) Or (*pos\lineNr > *range\pos2\lineNr))
		
		If includeBorder
			ProcedureReturnIf((*pos\lineNr = *range\pos1\lineNr) And (*pos\charNr <= *range\pos1\charNr))
			ProcedureReturnIf((*pos\lineNr = *range\pos2\lineNr) And (*pos\charNr >= *range\pos2\charNr))
		Else
			ProcedureReturnIf((*pos\lineNr = *range\pos1\lineNr) And (*pos\charNr < *range\pos1\charNr))
			ProcedureReturnIf((*pos\lineNr = *range\pos2\lineNr) And (*pos\charNr > *range\pos2\charNr))
		EndIf
		
		If (*pos\lineNr = *range\pos1\lineNr) And (*pos\lineNr = *range\pos2\lineNr)
			If Abs(*pos\charNr - *range\pos1\charNr) < Abs(*pos\charNr - *range\pos2\charNr)
				ProcedureReturn -1
			Else
				ProcedureReturn 1
			EndIf
		ElseIf Abs(*pos\lineNr - *range\pos1\lineNr) < Abs(*pos\lineNr - *range\pos2\lineNr)
			ProcedureReturn -1
		Else
			ProcedureReturn 1
		EndIf
		
		ProcedureReturn 0
	EndProcedure
	
	Procedure Position_InsideSelection(*te.TE_STRUCT, *view.TE_VIEW, screenX, screenY, checkBorder = #False)
		; test if the screen-position screenX/screenY is insinde a selection
		;
		; returnvalues:	*cursor - selection found
		;				#Null	- no selection found
		
		ProcedureReturnIf((*te = #Null) Or (*view = #Null))
		
		Protected *result.TE_CURSOR
		Protected selection.TE_RANGE
		Protected selText.s
		Protected pos.TE_POSITION
		
		pos\lineNr = Textline_LineNrFromScreenPos(*te, *view, screenY)
		pos\charNr = Textline_CharNrFromScreenPos(*te, Textline_FromLine(*te, pos\lineNr), screenX - *te\leftBorderOffset + *view\scroll\charX)
		
		PushListPosition(*te\cursor())
		ForEach *te\cursor()
			If Selection_Get(*te\cursor(), selection)
				If Position_InsideRange(pos, selection, checkBorder)
					*result = *te\cursor()
					Break
				EndIf
			EndIf
		Next
		PopListPosition(*te\cursor())
		
		ProcedureReturn *result
	EndProcedure
	
	Procedure Position_InsideString(*te.TE_STRUCT, lineNr, charNr)
		ProcedureReturnIf(*te = #Null)
		
		PushListPosition(*te\textLine())
		Protected i, result = 0
		Protected *textline.TE_TEXTLINE =  Textline_FromLine(*te, lineNr)
		
		If *textLine
			If Parser_TokenAtCharNr(*te, *textline, charNr - 1)
				For i = *te\parser\tokenIndex To 1 Step - 1
					If *textline\token(i)\type = #TE_Token_String
						result = 1
						Break
					EndIf
				Next
			EndIf
			If result And Parser_TokenAtCharNr(*te, *textline, charNr)
				For i = *te\parser\tokenIndex To *textline\tokenCount
					If *textline\token(i)\type = #TE_Token_String
						result = 2
						Break
					EndIf
				Next
			EndIf
		EndIf
		PopListPosition(*te\textLine())
		
		If result = 2
			ProcedureReturn #True
		Else
			ProcedureReturn #False
		EndIf
	EndProcedure
	
	Procedure Position_InsideComment(*te.TE_STRUCT, lineNr, charNr)
		ProcedureReturnIf(*te = #Null)
		
		Protected result = #False
		Protected i
		Protected *textline.TE_TEXTLINE
		
		PushListPosition(*te\textLine())
		*textline = Textline_FromLine(*te, lineNr)
		If *textLine
			If Parser_TokenAtCharNr(*te, *textline, charNr)
				For i = *te\parser\tokenIndex To 1 Step - 1
					If *textline\token(i)\type = #TE_Token_Comment
						result = #True
						Break
					EndIf
				Next
			EndIf
		EndIf
		PopListPosition(*te\textLine())
		
		ProcedureReturn result
	EndProcedure
	
	Procedure Position_Equal(*pos1.TE_POSITION, *pos2.TE_POSITION)
		ProcedureReturnIf((*pos1 = #Null) Or (*pos2 = #Null))
		
		If (*pos1\lineNr <> *pos2\lineNr) Or (*pos1\charNr <> *pos2\charNr)
			ProcedureReturn #False
		EndIf
		
		ProcedureReturn #True
	EndProcedure
	
	Procedure Position_Changed(*pos1.TE_POSITION, *pos2.TE_POSITION)
		ProcedureReturnIf((*pos1 = #Null) Or (*pos2 = #Null))
		
		If (*pos1\lineNr <> *pos2\lineNr) Or (*pos1\charNr <> *pos2\charNr)
			ProcedureReturn #True
		EndIf
		
		ProcedureReturn #False
	EndProcedure
	
	;-
	;- ----------- TEXT -----------
	;-
	
	Procedure.s Text_Get(*te.TE_STRUCT, startLineNr, startCharNr, endLineNr, endCharNr)
		ProcedureReturnIf((*te = #Null) Or (ListSize(*te\textLine()) = 0), "")
		ProcedureReturnIf((startLineNr < 1) Or (endLineNr <= 0), "")
		
		Protected size, nrLines
		Protected head.s, tail.s, *tail.Character
		
		If startLineNr > endLineNr
			Swap startLineNr, endLineNr
			Swap startCharNr, endCharNr
		ElseIf (startLineNr = endLineNr) And (startCharNr > endCharNr)
			Swap startCharNr, endCharNr
		EndIf
		
		startLineNr = Clamp(startLineNr, 1, ListSize(*te\textLine()))
		endLineNr = Clamp(endLineNr, 1, ListSize(*te\textLine()))
		nrLines = (endLineNr - startLineNr) + 1
		
		PushListPosition(*te\textLine())
		
		If SelectElement(*te\textLine(), startLineNr - 1)
			If nrLines = 1
				head.s = Mid(*te\textLine()\text + *te\newLineText, startCharNr, endCharNr - startCharNr)
			ElseIf nrLines > 1
				head = Mid(*te\textLine()\text + *te\newLineText, startCharNr)
				
				If nrLines = 2
					If NextElement(*te\textLine())
						tail = Left(*te\textLine()\text + *te\newLineText, endCharNr - 1)
					EndIf
				Else 
; 					calculate needed string size
					PushListPosition(*te\textLine())
					While (nrLines > 2) And NextElement(*te\textLine())
						size + Len(*te\textLine()\text + *te\newLineText)
						nrLines - 1
					Wend
					PopListPosition(*te\textLine())
					
					; create empty string
					tail = Space(size)
					*tail = @tail
					
					nrLines = (endLineNr - startLineNr) + 1
					While (nrLines > 2) And NextElement(*te\textLine())
						PokeS(*tail, *te\textLine()\text + *te\newLineText)
						*tail + StringByteLength(*te\textLine()\text + *te\newLineText)
						nrLines - 1
					Wend
					
					If NextElement(*te\textLine())
						tail + Left(*te\textLine()\text + *te\newLineText, endCharNr - 1)
					EndIf
				EndIf
			EndIf
		EndIf
		
		PopListPosition(*te\textLine())
		
		ProcedureReturn head + tail
	EndProcedure
	
	Procedure.s Text_Cut(text.s, startPos, length = 0)
		If text
			If length = 0
				ProcedureReturn Left(text, startPos - 1)
			Else
				ProcedureReturn Left(text, startPos - 1) + Mid(text, startPos + length)
			EndIf
		EndIf
		ProcedureReturn ""
	EndProcedure
	
	Procedure.s Text_Replace(text.s, replaceText.s, pos)
		text = Left(text, pos - 1) + 
		       Left(replaceText, Len(text) - pos + 1) + 
		       Mid(text, pos + Len(replaceText))
		ProcedureReturn text
	EndProcedure
	
	Procedure.s TokenText(*token.TE_TOKEN)
		If *token And (*token\size > 0)
			ProcedureReturn PeekS(*token\text, *token\size)
		EndIf
		ProcedureReturn ""
	EndProcedure
	
	
	;-
	;- ----------- UNDO -----------
	;-
	
	Procedure Undo_Start(*te.TE_STRUCT, *undo.TE_UNDO)
		ProcedureReturnIf((*te = #Null) Or (*undo = #Null) Or GetFlag(*te, #TE_EnableUndo) = 0)
		
		Protected result = ListSize(*undo\entry())
		Undo_Add(*te, *undo, #TE_Undo_Start)
		
		ProcedureReturn result
	EndProcedure
	
	Procedure Undo_Add(*te.TE_STRUCT, *undo.TE_UNDO, action, startLineNr = 0, startCharNr = 0, endLineNr = 0, endCharNr = 0, text.s = "")
		ProcedureReturnIf((*undo = #Null) Or GetFlag(*te, #TE_EnableUndo) = 0)
		
		Protected *entry.TE_UNDOENTRY = LastElement(*undo\entry())
		
		If action = #TE_Undo_Start
			If *entry And (*entry\action = #TE_Undo_Start)
				; prevent adding multiple undo-start-markers
				ProcedureReturn #Null
			EndIf
		ElseIf (action = #TE_Undo_AddText) And ((startLineNr = endLineNr) And (startCharNr = endCharNr))
			ProcedureReturn #Null
		ElseIf (action = #TE_Undo_DeleteText) And text = ""
			ProcedureReturn #Null
		EndIf
		
		*entry = AddElement(*undo\entry())
		If *entry
			*entry\action = action
			*entry\text = text
			*entry\startPos\lineNr = startLineNr
			*entry\startPos\charNr = startCharNr
			*entry\endPos\lineNr = endLineNr
			*entry\endPos\charNr = endCharNr
			
; 			Select action
; 				Case #TE_Undo_Start
; 					Debug ""
					;Debug "  undo start (Undo-ID " + Str(*undo) + ")"
; 				Case #TE_Undo_AddText
; 					Debug "  add text at: " + 
; 					      "start <" + Str(*entry\startPos\lineNr) + ", " + Str(*entry\startPos\charNr) + "] end <" + Str(*entry\endPos\lineNr) + ", " + Str(*entry\endPos\charNr) + "]"
; 				Case #TE_Undo_ChangeText
; 					Debug "  change text at: " + 
; 					      "start <" + Str(*entry\startPos\lineNr) + ", " + Str(*entry\startPos\charNr) + "]"
; 				Case #TE_Undo_DeleteText
; 					Debug "  delete text: " + ReplaceString(ReplaceString(*entry\text, Chr(10), "<\n]"), #TAB$, "<TAB]")
; 					Debug "  start <" + Str(*entry\startPos\lineNr) + ", " + Str(*entry\startPos\charNr) + "]"
; 			EndSelect
			
		EndIf
		
		ProcedureReturn *entry
	EndProcedure
	
	Procedure Undo_Do(*te.TE_STRUCT, *undo.TE_UNDO, *redo.TE_UNDO)
		ProcedureReturnIf((*te = #Null) Or (*undo = #Null) Or (*redo = #Null))
		
		Protected quit
		Protected *entry.TE_UNDOENTRY = LastElement(*undo\entry())
		
		If *entry = #Null
			ProcedureReturn #False
		EndIf
		
		Protected dictionaryEnabled = GetFlag(*te, #TE_EnableDictionary)
		SetFlag(*te, #TE_EnableDictionary, 0)
		
		Selection_ClearAll(*te, #True)
		
		Undo_Add(*te, *redo, #TE_Undo_Start)
		
		Repeat
			Select *entry\action
					
				Case #TE_Undo_Start
					
					quit = #True
					
				Case #TE_Undo_AddText
					
					Cursor_Position(*te, *te\currentCursor, *entry\startPos\lineNr, *entry\startPos\charNr, #False, #False)
					Selection_SetRange(*te, *te\currentCursor, *entry\endPos\lineNr, *entry\endPos\charNr, #False, #False)
					Selection_Delete(*te, *te\currentCursor, *redo)
					
				Case #TE_Undo_DeleteText
					
					Cursor_Position(*te, *te\currentCursor, *entry\startPos\lineNr, *entry\startPos\charNr, #False, #False)
					Textline_AddText(*te, *te\currentCursor, @*entry\text, Len(*entry\text), #TE_Styling_UpdateFolding | #TE_Styling_UpdateIndentation, *redo)
					
				Case #TE_Undo_ChangeText
					
					Textline_ChangeText(*te, Textline_FromLine(*te, *entry\startPos\lineNr), *entry\startPos\charNr, *entry\text, *redo)
					Cursor_Position(*te, *te\currentCursor, *entry\endPos\lineNr, *entry\endPos\charNr, #False, #False)
					
				Case #TE_Undo_AddRemark
					
					Textline_DeleteRemark(*te, *entry\startPos\lineNr, *redo)
					
				Case #TE_Undo_DeleteRemark
					
					Textline_AddRemark(*te, *entry\startPos\lineNr + 1, *entry\startPos\charNr, *entry\text, *redo)
					
			EndSelect
			
			; 			If *te\needFoldUpdate
			; 				Folding_Update(*te, -1, -1)
			; 			EndIf
			
			*entry = DeleteElement(*undo\entry())
		Until quit Or (*entry = #Null)
		
		Selection_ClearAll(*te, #True)
		
		If *te\needFoldUpdate
			Folding_Update(*te, -1, -1)
		EndIf
		Scroll_Update(*te, *te\currentView, *te\currentCursor, -1, -1)
		
		SetFlag(*te, #TE_EnableDictionary, dictionaryEnabled)
		Autocomplete_UpdateDictonary(*te, 0, 0)
		
		PostEvent(#TE_Event_Redraw, 0, 0, #TE_EventType_RedrawAll, *te\view)
		
		ProcedureReturn #True
	EndProcedure
	
	
	Procedure Undo_Update(*te.TE_STRUCT)
		; remove undo-start-markers from end of undo list
		
		ProcedureReturnIf((*te = #Null) Or (*te\undo = #Null) Or GetFlag(*te, #TE_EnableUndo) = 0)
		
		Protected result = #False
		
		While LastElement(*te\undo\entry())
			If *te\undo\entry()\action = #TE_Undo_Start
				DeleteElement(*te\undo\entry())
				result = #True
			Else
				Break
			EndIf
		Wend
		
		While LastElement(*te\redo\entry())
			If *te\redo\entry()\action = #TE_Undo_Start
				DeleteElement(*te\redo\entry())
				result = #True
			Else
				Break
			EndIf
		Wend
		
		ProcedureReturn result
	EndProcedure
	
	Procedure Undo_Clear(*undo.TE_UNDO)
		If *undo
			ClearList(*undo\entry())
		EndIf
	EndProcedure
	
	;-
	;- ----------- KEYWORD -----------
	;-
	
	
	Procedure KeyWord_Add(*te.TE_STRUCT, keyword.s, style = #TE_Ignore, caseCorrection = #TE_Ignore)
		ProcedureReturnIf(*te = #Null)
		
		Protected *key.TE_KEYWORD
		Protected key.s = LCase(keyword)
		
		*key = FindMapElement(*te\keyWord(), key)
		If *key = #Null
			*key = AddMapElement(*te\keyWord(), key)
			If *key
				*key\name = keyword
			EndIf
		EndIf
		
		If *key
			If style <> #TE_Ignore
				*key\style = style
			EndIf
			
			If caseCorrection <> #TE_Ignore
				*key\caseCorrection = caseCorrection
			EndIf
		EndIf
		
		ProcedureReturn *key
	EndProcedure
	
	Procedure KeyWord_LineContinuation(*te.TE_STRUCT, keywordList.s)
		; keywordList is a list of keywords separated by chr(10)
		
		ProcedureReturnIf((*te = #Null) Or (keywordList = ""))
		
		Protected count = CountString(keywordList, Chr(10))
		Protected keyword.s
		Protected i
		
		For i = 1 To count + 1
			keyword = LCase(StringField(keywordList, i, Chr(10)))
			If keyword
				AddMapElement(*te\keyWordLineContinuation(), keyword)
			EndIf
		Next
	EndProcedure
	
	Procedure KeyWord_Folding(*te.TE_STRUCT, keyword.s, foldState)
		ProcedureReturnIf(*te = #Null)
		
		Protected *keyword.TE_KEYWORD
		
		*keyword = KeyWord_Add(*te, keyword)
		If *keyword <> #Null
			*keyword\foldState = foldState
		EndIf
		
		ProcedureReturn *keyword
	EndProcedure
	
	Procedure KeyWord_Indentation(*te.TE_STRUCT, keyword.s, indentationBefore, indentationAfter)
		ProcedureReturnIf(*te = #Null)
		
		Protected *keyword.TE_KEYWORD
	
		*keyword = KeyWord_Add(*te, keyword)
		If *keyword <> #Null
			*keyword\indentationBefore = indentationBefore
			*keyword\indentationAfter = indentationAfter
		EndIf
		
		ProcedureReturn *keyword
	EndProcedure
	
	Procedure Syntax_Add(*te.TE_STRUCT, text.s, flags = #TE_Parser_Multiline)
		ProcedureReturnIf(*te = #Null)
		
		Protected nrParts, nrValues, valueStart
		Protected part.s, key.s, values.s, valL.s, value.s
		Protected i, j
		
		If Right(text, 1) <> "'"
			text + "'"
		EndIf
		
		nrParts = CountString(text, "|") + 1
		For i = 1 To nrParts
			part.s = StringField(text, i, "|")
			key.s = Left(part, FindString(part, "'") - 1)
			
			If key
				*te\syntax(LCase(key))\keyWord = key
				*te\syntax(LCase(key))\flags | flags
				
				valueStart = FindString(part, "'")
				values.s = Mid(part, valueStart + 1, FindString(part, "'", valueStart + 1) - valueStart - 1)
				If values
					nrValues = CountString(values, ",") + 1
					For j = 1 To nrValues
						value = StringField(values, j, ",")
						valL = LCase(value)
						
						*te\syntax(valL)\keyWord = value
						*te\syntax(valL)\flags | flags
						
						*te\syntax(valL)\before(LCase(key))\keyWord = key
						*te\syntax(LCase(key))\after(valL)\keyWord = value
					Next
				EndIf
			EndIf
		Next
		
		ForEach *te\syntax()
			If (MapSize(*te\syntax()\before()) = 0) And MapSize(*te\syntax()\after())
				*te\syntax()\flags | #TE_Syntax_Start
			EndIf
			If (MapSize(*te\syntax()\after()) = 0) And MapSize(*te\syntax()\before())
				*te\syntax()\flags | #TE_Syntax_End
			EndIf
		Next
	EndProcedure
	
	;-
	;- ----------- FOLDING -----------
	;-
	
	Procedure Folding_GetTextBlock(*te.TE_STRUCT, lineNr, foldstate = 0)
		ProcedureReturnIf(*te = #Null)
		
		Protected *textBlock.TE_TEXTBLOCK = #Null

		PushListPosition(*te\textBlock())
		ForEach *te\textBlock()
			If (lineNr >= *te\textBlock()\firstLineNr) And (lineNr <= *te\textBlock()\lastLineNr Or *te\textBlock()\lastLineNr = 0)
				If (foldstate = 0) Or (*te\textBlock()\firstLine And (*te\textBlock()\firstLine\foldState = foldstate))
					*textBlock = *te\textBlock()
					;Break
				EndIf
			EndIf
		Next
		PopListPosition(*te\textBlock())
		
		ProcedureReturn *textBlock
	EndProcedure
	
	Procedure Folding_Update(*te.TE_STRUCT, firstLine, lastLine)
		ProcedureReturnIf(*te = #Null)
		
		If GetFlag(*te, #TE_EnableFolding) = 0
			*te\needFoldUpdate = #False
			
			*te\visibleLineCount = ListSize(*te\textLine())
			ProcedureReturn
		EndIf
		
		Protected *previousBlock.TE_TEXTBLOCK
		Protected *textBlock.TE_TEXTBLOCK
		Protected *foldBlock.TE_TEXTBLOCK
		Protected foldCount, foldSum
		Protected visibleLineNr
		Protected oldWordWrapSize = *te\wordWrapSize
		Protected lineNr
		
		*te\needFoldUpdate = #False
		*te\redrawMode | #TE_Redraw_All
		
		*te\visibleLineCount = ListSize(*te\textLine())
		
		ClearList(*te\textBlock())
		
		PushListPosition(*te\textLine())
		
		ForEach *te\textLine()
			
			If *te\textLine()\remark
				*te\textLine()\lineNr = lineNr + 1
			Else
				lineNr + 1
				*te\textLine()\lineNr = lineNr
			EndIf
			
			If *foldBlock = #Null
				visibleLineNr + 1
			EndIf
			
			*te\textLine()\foldSum = foldSum
			
			If *te\textLine()\foldState
				foldSum = Max(0, foldSum + *te\textLine()\foldCount)
				
				If *te\textLine()\foldCount > 0
					foldCount + *te\textLine()\foldCount
					
					While foldCount > 0
						*textBlock = AddElement(*te\textBlock())
						If *textBlock
							*textBlock\firstLine = *te\textLine()
							*textBlock\firstLineNr = ListIndex(*te\textLine()) + 1
							*textBlock\firstVisibleLineNr = visibleLineNr
							
							If *foldBlock = #Null
								If *textBlock\firstLine\foldState = #TE_Folding_Folded
									*foldBlock = *textBlock
								EndIf
							EndIf
						EndIf
						
						foldCount - 1
					Wend
					
				ElseIf (*te\textLine()\foldCount < 0) And (*te\textLine()\foldSum > 0)
					
					foldCount = *te\textLine()\foldCount
					
					While *textBlock And (foldCount < 0)
						If *textBlock\lastLine = #Null
							*textBlock\lastLine = *te\textLine()
							*textBlock\lastLineNr = ListIndex(*te\textLine()) + 1
							*textBlock\lastVisibleLineNr = visibleLineNr
						EndIf
						
						If *textBlock = *foldBlock
							*te\visibleLineCount - (*foldBlock\lastLineNr - *foldBlock\firstLineNr)
							*foldBlock = #Null
						EndIf
						
						If PreviousElement(*te\textBlock())
							*textBlock = *te\textBlock()
						EndIf
						
						foldCount + 1
					Wend
				EndIf
				
			EndIf
			
		Next
		
		PopListPosition(*te\textLine())
		
		If *foldBlock
			*te\visibleLineCount - (ListSize(*te\textLine()) - *foldBlock\firstLineNr)
		EndIf
		
		SortStructuredList(*te\textBlock(), #PB_Sort_Ascending, OffsetOf(TE_TEXTBLOCK\firstLineNr), TypeOf(TE_TEXTBLOCK\firstLineNr))
		
		PushListPosition(*te\cursor())
		ForEach *te\cursor()
			*te\cursor()\position\visibleLineNr = LineNr_to_VisibleLineNr(*te, *te\cursor()\position\lineNr)
		Next
		PopListPosition(*te\cursor())
	EndProcedure
	
	Procedure Folding_Toggle(*te.TE_STRUCT, lineNr)
		ProcedureReturnIf(*te = #Null)
		
		PushListPosition(*te\textBlock())
		Protected *textblock.TE_TEXTBLOCK = Folding_GetTextBlock(*te, lineNr)
		
 		Protected scrollLineNr = LineNr_from_VisibleLineNr(*te, *te\currentView\scroll\visibleLineNr)
		
		If *textblock
			If *textblock\firstLine\foldState = #TE_Folding_Folded
				*textblock\firstLine\foldState = #TE_Folding_Unfolded
			ElseIf *textblock\firstLine\foldState = #TE_Folding_Unfolded
				*textblock\firstLine\foldState = #TE_Folding_Folded
			EndIf
			
			scrollLineNr = Min(scrollLineNr, *textblock\firstLineNr)
			*te\redrawMode | #TE_Redraw_All
		EndIf
		PopListPosition(*te\textBlock())
		
		Folding_Update(*te, -1, -1)
		
		Scroll_Line(*te, *te\currentView, *te\currentCursor, LineNr_to_VisibleLineNr(*te, scrollLineNr))
		
		*te\needFoldUpdate = #True
		*te\needScrollUpdate = #False
		
		ProcedureReturn *textblock
	EndProcedure
	
	Procedure Folding_ToggleAll(*te.TE_STRUCT)
		ProcedureReturnIf(*te = #Null)
		
; 		Protected scrollLineNr = LineNr_from_VisibleLineNr(*te, *te\currentView\scroll\visibleLineNr)
		Protected scrollLineNr = *te\currentCursor\position\lineNr
		
		ForEach *te\textBlock()
			With *te\textBlock()
				If \firstLine\foldState = #TE_Folding_Folded
					\firstLine\foldState = #TE_Folding_Unfolded
				ElseIf \firstLine\foldState = #TE_Folding_Unfolded
					\firstLine\foldState = #TE_Folding_Folded
				EndIf
			EndWith
		Next
		
		Folding_Update(*te, -1, -1)
		
		Scroll_Line(*te, *te\currentView, *te\currentCursor, LineNr_to_VisibleLineNr(*te, scrollLineNr))
		
		*te\needFoldUpdate = #True
		*te\needScrollUpdate = #False
	EndProcedure
	
	Procedure Folding_UnfoldTextline(*te.TE_STRUCT, lineNr, updateFolding = #True)
		ProcedureReturnIf(*te = #Null)
		
		Protected foldFound = #False
		
		PushListPosition(*te\textBlock())		
		ForEach *te\textBlock()
			If *te\textBlock()\firstLine
				If (lineNr >= *te\textBlock()\firstLineNr) And (lineNr <= *te\textBlock()\lastLineNr Or *te\textBlock()\lastLineNr = 0)
					*te\textBlock()\firstLine\foldState = #TE_Folding_Unfolded
					*te\needFoldUpdate = #True
					foldFound = #True
				EndIf
			EndIf
		Next
		PopListPosition(*te\textBlock())
		
		If updateFolding And *te\needFoldUpdate
			Folding_Update(*te, -1, -1)
			*te\redrawMode = #TE_Redraw_All
		EndIf
		
		ProcedureReturn foldFound
	EndProcedure
	
	Procedure Folding_RemoveTextblock(*te.TE_STRUCT, lineNr)
		ProcedureReturnIf(*te = #Null)
		
		Protected *textblock.TE_TEXTBLOCK = Folding_GetTextBlock(*te, lineNr)

		If *textblock
			If *textblock\firstLine
				*textblock\firstLine\foldState = 0
				*textblock\firstLine\foldCount = Max(*textblock\firstLine\foldCount - 1, 0)
			EndIf
			If *textblock\lastLine
				*textblock\lastLine\foldState = 0
				*textblock\lastLine\foldCount = Min(*textblock\lastLine\foldCount + 1, 0)
			EndIf
		EndIf
		
		ProcedureReturn *textblock
	EndProcedure
	
	Procedure Folding_AddTextblock(*te.TE_STRUCT, startLineNr, endLineNr)
		ProcedureReturnIf(*te = #Null)
		
		Protected result = #False
		
		If startLineNr > endLineNr
			Swap startLineNr, endLineNr
		EndIf
		
		PushListPosition(*te\textLine())
		If Textline_FromLine(*te, startLineNr)
			If (startLineNr < endLineNr) And (*te\textLine()\foldState = 0)
				*te\textLine()\foldState = #TE_Folding_Folded
				*te\textLine()\foldCount + 1
				If Textline_FromLine(*te, endLineNr)
					*te\textLine()\foldState = #TE_Folding_End
					*te\textLine()\foldCount -1
				EndIf
				result = #True
			Else
				result = Folding_RemoveTextblock(*te, startLineNr)
			EndIf
		EndIf
		PopListPosition(*te\textLine())
		
		ProcedureReturn result
	EndProcedure
	
	;-
	;- ----------- INDENTATION -----------
	;-
	
	Procedure.s Indentation_Text(*te.TE_STRUCT, indentation.s, indentationCount)
		ProcedureReturnIf((*te = #Null) Or (indentationCount = 0), indentation)
		
		Protected i, j
		
		If indentationCount > 0
			
			If *te\useRealTab
				indentation + LSet("", indentationCount, #TAB$)
			Else
				indentation + LSet("", indentationCount * *te\tabSize, " ")
			EndIf
			
		ElseIf indentationCount < 0
			
			For i = indentationCount To -1
				If Left(indentation, 1) = #TAB$
					indentation = Mid(indentation, 2)
				ElseIf Left(indentation, *te\tabSize) = Space(*te\tabSize)
					indentation = Mid(indentation, *te\tabSize + 1)
				ElseIf Left(indentation, 1) = " "
					For j = 1 To *te\tabSize
						If Mid(indentation, j, 1) <> " "
							indentation = Mid(indentation, j)
							Break
						EndIf
					Next
				EndIf
			Next
			
		EndIf
		
		ProcedureReturn indentation
	EndProcedure
	
	Procedure.s Indentation_LineContinuation(*te.TE_STRUCT, *textLine.TE_TEXTLINE)
		ProcedureReturnIf((*te = #Null) Or (*textLine = #Null) Or (*textLine\tokenCount = 0), "")
		
		Protected *firstLine.TE_TEXTLINE
		Protected *currentLine.TE_TEXTLINE = *textLine
		Protected NewList indent.TE_INDENTATIONPOS(), indent.TE_INDENTATIONPOS
		Protected lineNr, i, newIndent, nextIndent, firstIndent
		
		PushListPosition(*te\textLine())
		ChangeCurrentElement(*te\textLine(), *textLine)
		
		lineNr = ListIndex(*te\textLine())
		While PreviousElement(*te\textLine()) And Textline_HasLineContinuation(*te, *te\textLine())
			*textLine = *te\textLine()
		Wend
		
		*firstLine = *textLine
		ChangeCurrentElement(*te\textLine(), *textLine)
		Repeat
			For i = 1 To *textLine\tokenCount
				If nextIndent And (*textline\token(i)\type = #TE_Token_String)
					newIndent = 1
					nextIndent = 0
				EndIf
				If newIndent And (*textline\token(i)\type <> #TE_Token_Whitespace)
					newIndent = 0
					nextIndent = 0
					indent\textLine = *textLine
					indent\charNr = *textLine\token(i)\charNr
				EndIf
				
				Select *textline\token(i)\type
					Case #TE_Token_Comment
						Break
					Case #TE_Token_Operator
					Case #TE_Token_Comma
						nextIndent = 1
					Case #TE_Token_Equal
						;nextIndent = 1
						newIndent = 1
; 						AddElement(indent())
; 						CopyStructure(indent, indent(), TE_INDENTATIONPOS)
					Case #TE_Token_BracketOpen
						newIndent = 1
						AddElement(indent())
						CopyStructure(indent, indent(), TE_INDENTATIONPOS)
					Case #TE_Token_BracketClose
						If LastElement(indent())
							CopyStructure(indent(), indent, TE_INDENTATIONPOS)
							DeleteElement(indent())
						EndIf
				EndSelect
				
				If indent\charNr = 0
					If firstIndent = 0 And *textline\token(i)\type <> #TE_Token_Whitespace
						firstIndent = 1
					ElseIf firstIndent = 1 And *textline\token(i)\type = #TE_Token_Whitespace
						firstIndent = 2
						newIndent = 1
					EndIf
				EndIf
			Next
			*textLine = NextElement(*te\textLine())
		Until (ListIndex(*te\textLine()) > lineNr) Or (*textLine = #Null)
		
		PopListPosition(*te\textLine())
		
		If indent\textLine
			i = Textline_ColumnFromCharNr(*te, *te\currentView, indent\textLine, indent\charNr) - 1
			If *te\useRealTab
				ProcedureReturn RSet("", i / *te\tabSize, #TAB$) + Space(i % *te\tabSize)
			Else
				ProcedureReturn Space(i)
			EndIf
		EndIf
	EndProcedure
	
	Procedure.s Indentation_Before(*te.TE_STRUCT, *textLine.TE_TEXTLINE, mode = #TE_Indentation_Auto)
		ProcedureReturnIf((*te = #Null) Or (*textLine = #Null), "")
		
		Protected *previousLine.TE_TEXTLINE = #Null
		Protected *lineContiuation.TE_TEXTLINE = #Null
		Protected *indentation.TE_TOKEN = #Null
		Protected indentationCount = 0
		
		PushListPosition(*te\textLine())
		ChangeCurrentElement(*te\textLine(), *textLine)
		
		If mode = #TE_Indentation_Auto
			
			While PreviousElement(*te\textLine()) And TextLine_IsEmpty(*te\textLine())
			Wend
			*previousLine = *te\textLine()
			
			While PreviousElement(*te\textLine()) And Textline_HasLineContinuation(*te, *te\textLine())
				*previousLine = *te\textLine()
			Wend
			
			If *previousLine And *previousLine\lineNr > 1
				If *previousLine\tokenCount >= 1
					If *previousLine\token(1)\type = #TE_Token_Whitespace
						*indentation = @*previousLine\token(1)
					Else
						*indentation = #Null
					EndIf
				EndIf
				indentationCount = *previousLine\indentationAfter
			Else
				indentationCount = 0
				*indentation = #Null
			EndIf
			
		ElseIf mode = #TE_Indentation_Block
			
			*previousLine = *te\textLine()
			While *previousLine And (*previousLine\tokenCount = 0)
				*previousLine = PreviousElement(*te\textLine())
			Wend
			
			If *previousLine And *previousLine\tokenCount And *previousLine\token(1)\type = #TE_Token_Whitespace
				*indentation = @*previousLine\token(1)
			EndIf
			
		EndIf
		PopListPosition(*te\textLine())
		
		If *indentation
			ProcedureReturn Indentation_Text(*te, TokenText(*indentation), indentationCount)
		Else
			ProcedureReturn Indentation_Text(*te, "", indentationCount)
		EndIf
	EndProcedure
	
	Procedure Indentation_Range(*te.TE_STRUCT, firstLineNr, lastLineNr, *cursor.TE_CURSOR = #Null, mode = #TE_Indentation_Auto)
		ProcedureReturnIf((*te = #Null) Or (GetFlag(*te, #TE_EnableIndentation) = 0))
		
		Protected *textline.TE_TEXTLINE, *previousTextline.TE_TEXTLINE
		Protected indentationCount, indentation.s, hasLineContinuation, continueLine
		Protected previousIndentationCount, previousIndentation.s, previousHasLineContinuation
		
		If lastLineNr <= 0
			lastLineNr = firstLineNr
		EndIf
		
		If firstLineNr > lastLineNr
			Swap firstLineNr, lastLineNr
		EndIf
		
		PushListPosition(*te\textLine())
		
		If Textline_FromLine(*te, firstLineNr)
			indentation = Indentation_Before(*te, *te\textLine(), mode)
			
			PushListPosition(*te\textLine())
			*previousTextline = PreviousElement(*te\textLine())
			hasLineContinuation = Textline_HasLineContinuation(*te, *previousTextline)
			PopListPosition(*te\textLine())
			
			If mode = #TE_Indentation_Auto
				
				Repeat
					previousHasLineContinuation = hasLineContinuation
					hasLineContinuation = Textline_HasLineContinuation(*te, *te\textLine())
					
					If previousHasLineContinuation
						indentation = Indentation_LineContinuation(*te, *previousTextline)
					Else
						If continueLine
							continueLine = 0
							indentation = previousIndentation
 							indentationCount = previousIndentationCount
						EndIf
						indentation = Indentation_Text(*te, indentation, indentationCount + *te\textLine()\indentationBefore)
						indentationCount = *te\textLine()\indentationAfter
						If hasLineContinuation And (continueLine = 0)							
							continueLine = 1
 							previousIndentation = indentation
 							previousIndentationCount = indentationCount
 						EndIf
					EndIf
					
					Textline_SetText(*te, *te\textLine(), indentation + Indentation_Clear(*te\textLine()), #TE_Styling_UpdateIndentation, *te\undo)
					
					If ListIndex(*te\textLine()) >= lastLineNr - 1
						Break
					EndIf
					
					*previousTextline = *te\textLine()
				Until NextElement(*te\textLine()) = #Null

				If Textline_HasLineContinuation(*te, *previousTextline)
					indentation = Indentation_LineContinuation(*te, *previousTextline)
				Else
					indentation = Indentation_Before(*te, *previousTextline)
				EndIf
				
			ElseIf mode = #TE_Indentation_Block
				
				Repeat
					Textline_SetText(*te, *te\textLine(), indentation + Indentation_Clear(*te\textLine()), #TE_Styling_UpdateIndentation, *te\undo)
				Until (ListIndex(*te\textLine()) >= lastLineNr - 1) Or (NextElement(*te\textLine()) = #Null)
				
			EndIf
		EndIf
		PopListPosition(*te\textLine())
		
		If *cursor
			Cursor_Position(*te, *cursor, lastLineNr, Textline_LastCharNr(*te, lastLineNr))
			*cursor\position\currentX = Textline_CharNrToScreenPos(*te, *cursor\position\textline, *cursor\position\charNr)
			Selection_SetRange(*te, *cursor, firstLineNr, 1)
		EndIf
		
		ProcedureReturn Len(indentation) + 1
	EndProcedure
	
	Procedure Indentation_All(*te.TE_STRUCT)
		ProcedureReturnIf(*te = #Null)
		
		Indentation_Range(*te, 1, ListSize(*te\textLine()), #Null, #TE_Indentation_Auto)
	EndProcedure
	
	Procedure.s Indentation_Clear(*textLine.TE_TEXTLINE)
		ProcedureReturnIf((*textLine = #Null) Or (*textLine\tokenCount < 1), "")
		
		If (*textLine\tokenCount = 1) And (*textLine\token(1)\type = #TE_Token_Whitespace)
			ProcedureReturn ""
		ElseIf (*textLine\tokenCount > 1) And (*textLine\token(1)\type = #TE_Token_Whitespace)
			ProcedureReturn Mid(*textLine\text, *textLine\token(2)\charNr);PeekS(*textLine\token(2)\text)
		Else
			ProcedureReturn *textLine\text
		EndIf
	EndProcedure
	
	Procedure Indentation_Add(*te.TE_STRUCT, *cursor.TE_CURSOR)
		ProcedureReturnIf((*te = #Null) Or (*cursor = #Null) Or (*cursor\position\textline = #Null))
		
		Protected result = #False
		Protected charNr, tabPos
		Protected tabText.s
		
		charNr = Clamp(*cursor\position\charNr, 1, Textline_Length(*cursor\position\textline) + 1)
		
		If *te\useRealTab
			If Textline_AddChar(*te, *cursor, #TAB, #False, #TE_Styling_CaseCorrection | #TE_Styling_UpdateFolding | #TE_Styling_UpdateIndentation, *te\undo)
				result = #True
			EndIf
		Else
			tabPos = Textline_NextTabSize(*te, *cursor\position\textline, charNr)
			tabText.s = Space(tabPos)
			
			If Textline_AddText(*te, *cursor, @tabText, Len(tabText), #TE_Styling_CaseCorrection | #TE_Styling_UpdateFolding | #TE_Styling_UpdateIndentation, *te\undo)
				result = #True
			EndIf
		EndIf
		
		ProcedureReturn result
	EndProcedure
	
	Procedure Indentation_LTrim(*te.TE_STRUCT, *cursor.TE_CURSOR)
		ProcedureReturnIf((*te = #Null) Or (*cursor = #Null) Or (*cursor\position\textline = #Null))
		
		Protected result = #False
		Protected *textline.TE_TEXTLINE = *cursor\position\textline
		Protected charNr = 0
		
		If Mid(*textline\text, 1, 1) = #TAB$
			charNr = 2
		ElseIf Mid(*textline\text, 1, 1) = " "
			charNr = 1
			While (charNr <= *te\tabSize) And (Mid(*textline\text, charNr, 1) = " ")
				charNr + 1
			Wend
		EndIf
		
		If charNr
			Cursor_Position(*te, *cursor, *cursor\position\lineNr, charNr)
			Selection_SetRange(*te, *cursor, *cursor\position\lineNr, 1)
			result = Selection_Delete(*te, *cursor, *te\undo)
		EndIf
		
		ProcedureReturn result
	EndProcedure
	
	;-
	;- ----------- PARSER -----------
	;-
	
	Procedure Parser_Initialize(*parser.TE_PARSER)
		ProcedureReturnIf(*parser = #Null)
		
		Parser_Clear(*parser)
		
		Protected c
		
		For c = 0 To #TE_CharRange
			Select c
				Case 0
					*parser\tokenType(c) = #TE_Token_EOL
				Case 9, ' '
					*parser\tokenType(c) = #TE_Token_Whitespace
				Case '(', '[', '{'
					*parser\tokenType(c) = #TE_Token_BracketOpen
				Case ')', ']', '}'
					*parser\tokenType(c) = #TE_Token_BracketClose
				Case ','
					*parser\tokenType(c) = #TE_Token_Comma
				Case '.'
					*parser\tokenType(c) = #TE_Token_Point
				Case '0' To '9'
					*parser\tokenType(c) = #TE_Token_Number
				Case ':'
					*parser\tokenType(c) = #TE_Token_Colon
				Case '='
					*parser\tokenType(c) = #TE_Token_Equal
				Case 'a' To 'z', 'A' To 'Z', '_'
					*parser\tokenType(c) = #TE_Token_Text
				Case '\'
					*parser\tokenType(c) = #TE_Token_Backslash
					; Case '!', '$', '%', '&', '*', '+', '-', '/', '@', '|', '~', '#'
				Case '!', '%', '&', '*', '+', '-', '/', '|', '~'
					*parser\tokenType(c) = #TE_Token_Operator
				Case '<', '>'
					*parser\tokenType(c) = #TE_Token_Compare
				Default; 128-65535
					*parser\tokenType(c) = #TE_Token_Unknown
			EndSelect
		Next
	EndProcedure
	
	Procedure Parser_Clear(*parser.TE_PARSER)
		ProcedureReturnIf(*parser = #Null)
		
		*parser\state = 0
		*parser\tokenIndex = 0
		*parser\token = #Null
		*parser\textline = #Null
		*parser\lineNr = 0
	EndProcedure
	
	Procedure Parser_TokenAtCharNr(*te.TE_STRUCT, *textLine.TE_TEXTLINE, charNr, testBounds = #False, startIndex = 1)
		ProcedureReturnIf((*te = #Null) Or (*textLine = #Null) Or (*textLine\tokenCount = 0), #Null)
		
		If ArraySize(*textLine\token()) < 0
			Debug "Error in Procedure Parser_TokenAtCharNr: Array *textLine\token() not allocated"
			ProcedureReturn #Null
		EndIf
		
		Protected *token.TE_TOKEN = #Null
		Protected tokenIndex = 0
		Protected i
		
		If testBounds And (charNr < 1) Or (charNr > Len(*textLine\text))
			ProcedureReturn #Null
		EndIf
		
		If charNr <= 1
			tokenIndex = 1
		ElseIf charNr > Len(*textLine\text)
			tokenIndex = *textLine\tokenCount
		Else
			For i = startIndex To *textLine\tokenCount
				*token = @*textLine\token(i)
				If (charNr >= *token\charNr) And (charNr < (*token\charNr + *token\size))
					tokenIndex = i
					Break
				EndIf
			Next
		EndIf
		
		If tokenIndex
			*token = @*textLine\token(tokenIndex)
			*te\parser\textline = *textLine
			*te\parser\lineNr = Textline_LineNr(*te, *textLine)
			*te\parser\tokenIndex = tokenIndex
			*te\parser\token = *token
		EndIf
		
		ProcedureReturn *token
	EndProcedure
	
	Procedure Parser_NextToken(*te.TE_STRUCT, direction, flags = #TE_Parser_SkipWhiteSpace)
		ProcedureReturnIf((*te = #Null) Or (*te\parser\textline = #Null) Or (direction = 0))
		
		Protected *parser.TE_PARSER = *te\parser
		Protected *textline.TE_TEXTLINE = *parser\textline
		Protected *token.TE_TOKEN
		Protected tokenIndex = *parser\tokenIndex
		
		*parser\token = #Null
		
		ChangeCurrentElement(*te\textLine(), *textline)
		Repeat
			Protected endLoop = #True
			tokenIndex + direction
			
			If (tokenIndex < 1) Or (tokenIndex > *textline\tokenCount)
				
				; if multiline: keep looking for lines with tokens
				tokenIndex = 0
				If flags & #TE_Parser_Multiline
					If (direction < 0) And (ListIndex(*te\textLine()) > 0)
						Repeat
							*textline = PreviousElement(*te\textLine())
						Until (*textline = #Null) Or *textline\tokenCount
						If *textline And *textline\tokenCount
							tokenIndex = *textline\tokenCount
						Else
							*te\parser\state | #TE_Parser_State_EOF
						EndIf
					ElseIf (direction > 0) And (ListIndex(*te\textLine()) < ListSize(*te\textLine()) - 1)
						Repeat
							*textline = NextElement(*te\textLine())
						Until (*textline = #Null) Or *textline\tokenCount
						If *textline And *textline\tokenCount
							tokenIndex = 1
						Else
							*te\parser\state | #TE_Parser_State_EOF
						EndIf
					EndIf
				Else
					*parser\state | #TE_Parser_State_EOL
				EndIf
			EndIf
			
			If tokenIndex
				*token = @*textline\token(tokenIndex)
				
				If (flags & #TE_Parser_TextOnly) And (*token\type <> #TE_Token_Text)
					endLoop = #False
				ElseIf (flags & #TE_Parser_SkipWhiteSpace) And (*token\type = #TE_Token_Whitespace)
					endLoop = #False
				ElseIf (flags & #TE_Parser_SkipBlankLines) And ((*textline\tokenCount = 1) Or (*textline\tokenCount = 2 And *textline\token(1)\type = #TE_Token_Whitespace))
					endLoop = #False
				ElseIf (flags & #TE_Parser_IgnoreComments) And (*textline\style(*token\charNr) = #TE_Style_Comment)
					endLoop = #False
				EndIf
				
				If endLoop
					*parser\token = *token
					*parser\tokenIndex = tokenIndex
					*parser\textline = *textline
					*parser\lineNr = ListIndex(*te\textLine()) + 1
					*parser\state & ~#TE_Parser_State_EOL
				EndIf
			EndIf
		Until endLoop Or (*te\parser\state & #TE_Parser_State_EOF)
		
		ProcedureReturn *parser\token
	EndProcedure
	
	Procedure Parser_InsideStructure(*te.TE_STRUCT, *textline.TE_TEXTLINE, charNr)
		ProcedureReturnIf (*te = #Null Or (*textline = #Null))
		
		If Parser_TokenAtCharNr(*te, *textline, charNr) And (*te\parser\token\type = #TE_Token_Text)
			If Parser_NextToken(*te, -1) And (*te\parser\token\type = #TE_Token_Backslash)
				ProcedureReturn #True
			EndIf
		EndIf
		
		ProcedureReturn #False
	EndProcedure
	
	;-
	
	Procedure Tokenizer_GetNumber(*text.Character, *token.TE_TOKEN)
		Protected *c.Character = *text
		Protected size
		Protected decPointFound
		
		*token\type = #TE_Token_Number
		
		While *c\c
			Select *c\c
				Case '0' To '9'
					size + 1
				Case '.'
					If decPointFound
						Break
					EndIf
					decPointFound = 1
					size + 1
				Default
					Break
			EndSelect
			
			*c + #TE_CharSize
		Wend
		
		ProcedureReturn size
	EndProcedure
	
	Procedure Tokenizer_GetNumberBin(*text.Character, *token.TE_TOKEN)
		Protected *c.Character = *text
		Protected size
		Protected opFound
		
		While *c\c
			Select *c\c
				Case '%'
					If opFound = 0
						opFound = 1
						size + 1
					Else
						Break
					EndIf
				Case '0', '1'
					size + 1
				Default
					Break
			EndSelect
			
			*c + #TE_CharSize
		Wend
		
		If size > 1
			*token\type = #TE_Token_Quote
		Else
			*token\type = #TE_Token_Operator
		EndIf
		
		ProcedureReturn size
	EndProcedure
	
	Procedure Tokenizer_GetNumberHex(*text.Character, *token.TE_TOKEN)
		Protected *c.Character = *text
		Protected size
		Protected opFound
		
		While *c\c
			Select *c\c
				Case '$'
					If opFound = 0
						opFound = 1
						size + 1
					Else
						Break
					EndIf
				Case '0' To '9', 'A' To 'F', 'a' To 'f'
					size + 1
				Default
					Break
			EndSelect
			
			*c + #TE_CharSize
		Wend
		
		If size > 1
			*token\type = #TE_Token_Quote
		Else
			*token\type = #TE_Token_Unknown
		EndIf
		
		ProcedureReturn size
	EndProcedure
	
	Procedure Tokenizer_GetText(*text.Character, *token.TE_TOKEN, type = #TE_Token_Text)
		Protected *c.Character = *text
		Protected size
		
		*token\type = type
		
		While *c\c
			Select *c\c
				Case 'a' To 'z', 'A' To 'Z', '_'
					size + 1
					;Case 161 To #TE_CharRange
				Case 128 To #TE_CharRange
					size + 1
				Case '0' To '9'
					size + 1
				Default
					Break
			EndSelect
			
			*c + #TE_CharSize
		Wend
		
		ProcedureReturn size
	EndProcedure
	
	Procedure Tokenizer_GetComment(*text.Character, *commentChar.Character, length, *token.TE_TOKEN)
		Protected *c.Character = *text
		Protected size
		
		If CompareMemoryString(*text, *commentChar, #PB_String_CaseSensitive, length) = #PB_String_Equal
			*token\type = #TE_Token_Comment
			size = length
		EndIf
		
		ProcedureReturn size
	EndProcedure
	
	Procedure Tokenizer_GetWhiteSpace(*text.Character, *token.TE_TOKEN)
		Protected *c.Character = *text
		Protected size
		
		*token\type = #TE_Token_Whitespace
		
		While *c\c
			Select *c\c
				Case ' ', #TAB
					size + 1
				Default
					Break
			EndSelect
			
			*c + #TE_CharSize
		Wend
		
		ProcedureReturn size
	EndProcedure
	
	Procedure Tokenizer_Textline(*te.TE_STRUCT, *textline.TE_TEXTLINE)
		ProcedureReturnIf((*te = #Null) Or (*textline = #Null))
		
		Protected *c.Character
		Protected size
		Protected type
		Protected charNr = 1
		Protected token.TE_TOKEN
		Protected commentChar.c = Asc(Left(*te\commentChar, 1))
		Protected uncommentChar.c = Asc(Left(*te\uncommentChar, 1))
		Protected isComment = #False, isUncomment = #False, isQuoted = 0
		Protected maxTokens = ArraySize(*textline\token())
		Protected maxLength = Len(*textline\text) + 2
		
		*textline\tokenCount = 0
		
		*c = @*textline\text
		Repeat
			token\type = 0
			token\text = #Null
			size = 0
			
			If isQuoted = 0
				If *c\c = commentChar
					size = Tokenizer_GetComment(*c, @*te\commentChar, Len(*te\commentChar), @token)
					If size
						size = 0
						isComment = #True
						isUncomment = #False
					EndIf
				EndIf
				If *c\c = uncommentChar
					size = Tokenizer_GetComment(*c, @*te\uncommentChar, Len(*te\uncommentChar), @token)
					If size
						isComment = #False
						isUncomment = #True
					EndIf
				EndIf
			EndIf
			
			If size = 0 And (*c\c <= #TE_CharRange)
				token\type = *te\parser\tokenType(*c\c)
				
				size = 1
				Select token\type
					Case #TE_Token_Whitespace
						size = Tokenizer_GetWhiteSpace(*c, @token)
					Case #TE_Token_Number
						size = Tokenizer_GetNumber(*c, @token)
					Case #TE_Token_Text
						size = Tokenizer_GetText(*c, @token)
					Case #TE_Token_Operator
						If *c\c = '%'
							size = Tokenizer_GetNumberBin(*c, @token)
						EndIf
					Case #TE_Token_Unknown
						If *c\c = '$'
							size = Tokenizer_GetNumberHex(*c, @token)
						Else
							size = Tokenizer_GetText(*c, @token, #TE_Token_Unknown)
						EndIf
				EndSelect
			EndIf
			
			If size = 0
				size = 1
				token\type = #TE_Token_Unknown
			EndIf
			
			*textline\tokenCount + 1
			If *textline\tokenCount > maxTokens
				maxTokens + 16
				ReDim *textline\token(maxTokens)
			EndIf
			
			With *textline\token(*textline\tokenCount)
				\type = token\type
				\text = *c
				\charNr = charNr
				\size = size
				
				If *c\c
					If isComment
						\type = #TE_Token_Comment
						isComment = #False
						isUncomment = #False
					ElseIf isUncomment
						\type = #TE_Token_Uncomment
						isComment = #False
						isUncomment = #False
					ElseIf (isQuoted = 1) Or ((isQuoted = 0) And (*c\c = 39))
						\type = #TE_Token_Quote
						If *c\c = 39
							isQuoted = Bool(Not isQuoted)
						EndIf
					ElseIf (isQuoted = 2) Or ((isQuoted = 0) And (*c\c = '"'))
						\type = #TE_Token_String
						If *c\c = '"'
							isQuoted = Bool(Not isQuoted) * 2
						EndIf
					EndIf
				EndIf
			EndWith
			
			charNr + size
			*c + size * #TE_CharSize
		Until charNr >= maxLength; token\type = #TE_Token_EOL
		
		ProcedureReturn *textline\tokenCount
	EndProcedure
	
	Procedure Tokenizer_All(*te.TE_STRUCT)
		ProcedureReturnIf(*te = #Null)
		
		Protected tokenCount
		
		PushListPosition(*te\textLine())
		ForEach *te\textLine()
			tokenCount + Tokenizer_Textline(*te, *te\textLine())
		Next
		PopListPosition(*te\textLine())
		
		ProcedureReturn tokenCount
	EndProcedure
	
	
	;-
	;- ----------- SYNTAXHIGHLIGHT -----------
	;-
	
	Procedure SyntaxHighlight_Update(*te.TE_STRUCT)
		ProcedureReturnIf(*te = #Null)
		
		Protected *textline.TE_TEXTLINE
		Protected lineSize, pos1, pos2
		
		ForEach *te\syntaxHighlight()
			*textline = *te\syntaxHighlight()\textline
			lineSize = Textline_Length(*textline) + 1
			
			ReDim *textline\syntaxHighlight(lineSize * #TE_CharSize)
			
			pos1 = Clamp(*te\syntaxHighlight()\startCharNr, 1, lineSize)
			pos2 = Clamp(*te\syntaxHighlight()\endCharNr, 1, lineSize)
			
			*textLine\syntaxHighlight(pos1) = *te\syntaxHighlight()\style
			If *textLine\syntaxHighlight(pos2) = 0
				*textLine\syntaxHighlight(pos2) = #TE_Style_None
			EndIf
			*textline\needRedraw = #True
		Next
		
		*te\redrawMode | #TE_Redraw_ChangedLines
		*te\highlightSyntax = #True
		
		ProcedureReturn ListSize(*te\syntaxHighlight())
	EndProcedure
	
	Procedure SyntaxHighlight_Clear(*te.TE_STRUCT)
		ProcedureReturnIf((*te = #Null) Or (ListSize(*te\syntaxHighlight()) = 0))
		
		Protected *textline.TE_TEXTLINE
		
		*te\highlightSyntax = #False
		
		ForEach *te\syntaxHighlight()
			*textline = *te\syntaxHighlight()\textline
			If *textline And *textline\syntaxHighlight()
				FillMemory(@*textLine\syntaxHighlight(), ArraySize(*textLine\syntaxHighlight()), 0, #PB_Byte)
				*textline\needRedraw = #True
				*te\redrawMode | #TE_Redraw_ChangedLines
			EndIf
		Next
		
		ClearList(*te\syntaxHighlight())
	EndProcedure
	
	Procedure SyntaxHighlight_Find(*te.TE_STRUCT, direction, findFlags, skipFlags)
		ProcedureReturnIf((*te = #Null) Or (*te\parser\textline = #Null))
		ProcedureReturnIf(*te\parser\tokenIndex > *te\parser\textline\tokenCount)
		
		Protected *token.TE_TOKEN = #Null
		Protected *currentToken.TE_TOKEN = *te\parser\token
		Protected oldParser.TE_PARSER
		Protected skip
		
		CopyStructure(*te\parser, oldParser, TE_PARSER)
		Repeat
			*currentToken = Parser_NextToken(*te, direction, #TE_Parser_Multiline | #TE_Parser_TextOnly)
			If *currentToken
				If FindMapElement(*te\syntax(), LCase(TokenText(*currentToken)))
					If *te\syntax()\flags = skipFlags
						skip + 1
					ElseIf *te\syntax()\flags = findFlags
						If skip
							skip = Max(skip - 1, 0)
						Else
							*token = *currentToken
							Break
						EndIf
					EndIf
				EndIf
			EndIf
		Until *currentToken = #Null
		
		If *token = #Null
			CopyStructure(oldParser, *te\parser, TE_PARSER)
		EndIf
		
		ProcedureReturn *token
	EndProcedure
	
	Procedure SyntaxHighlight_Check(*te.TE_STRUCT, direction, flagStart, flagEnd, flags)
		ProcedureReturnIf((*te = #Null) Or (*te\parser\textline = #Null) Or (*te\parser\token = #Null) Or (direction = 0))
		
		Protected error = 0
		Protected result = 0
		Protected addResult
		Protected level = 0
		Protected procedureLevel = 0
		Protected loopLevel = 0
		Protected compilerLevel = 0
		Protected Dim *code(1024), codeLevel
		Protected *token.TE_TOKEN = *te\parser\token
		Protected *findToken.TE_TOKEN = *te\parser\token
		Protected *current.TE_SYNTAX
		Protected *previous.TE_SYNTAX
		
		Protected key.s
		
		ChangeCurrentElement(*te\textLine(), *te\parser\textline)
		
		Repeat
			addResult = #False
			
			key = LCase(TokenText(*token))
			*current = FindMapElement(*te\syntax(), key)
			If *current
				
				If (compilerLevel = 0) Or (*current\flags & #TE_Syntax_Compiler)
					
					If *current\flags & #TE_Syntax_Break
						If (flags & #TE_Syntax_Loop) And (loopLevel = 1)
							addResult = #True
						EndIf
					ElseIf *current\flags & #TE_Syntax_Continue
						If (flags & #TE_Syntax_Loop) And (loopLevel = 1)
							addResult = #True
						EndIf
					ElseIf *current\flags & #TE_Syntax_Return
						If (flags & #TE_Syntax_Procedure) And (procedureLevel = 1)
							addResult = #True
						EndIf
					Else
						If (level = 0) Or (*current\flags & flagStart)
							If codeLevel < 1024
								*code(codeLevel) = *previous
								codeLevel + 1
							EndIf
							
							If *current\flags & #TE_Syntax_Compiler
								compilerLevel + 1
							EndIf
							If *current\flags & #TE_Syntax_Loop
								loopLevel + 1
							EndIf
							If *current\flags & #TE_Syntax_Procedure
								procedureLevel + 1
							EndIf
							
							If level = 0
								addResult = #True
							EndIf
							
							If *current\flags & flagEnd
								result = 1
							EndIf
							
							level + direction
							
						ElseIf *previous
							
							If (direction > 0 And FindMapElement(*previous\after(), key)) Or
							   (direction < 0 And FindMapElement(*previous\before(), key))
								
								If *current\flags & flagEnd
									
									level - direction
									
									If *current\flags & #TE_Syntax_Compiler
										compilerLevel - 1
									EndIf					
									If *current\flags & #TE_Syntax_Loop
										loopLevel - 1
									EndIf
									If *current\flags & #TE_Syntax_Procedure
										procedureLevel - 1
									EndIf
									
									If codeLevel = 0
										error = #True
									Else
										codeLevel - 1
										*current = *code(codeLevel)
									EndIf
									
									If level = 0
										result = 1
									ElseIf ( (direction > 0) And (level < 0)) Or ( (direction < 0) And (level > 0))
										error = #True
									EndIf
									
								ElseIf Abs(level) = 1
									addResult = #True
								EndIf
								
							Else
								error = #True
							EndIf
							
						EndIf
						
						*previous = *current
					EndIf
					
				EndIf
				
			EndIf
			
			If error Or (result Or addResult)
				If AddElement(*te\syntaxHighlight())
					*te\parser\textline\needRedraw = #True
					*te\syntaxHighlight()\textline = *te\parser\textline
					*te\syntaxHighlight()\startCharNr = *token\charNr
					*te\syntaxHighlight()\endCharNr = *token\charNr + *token\size
					
					If error
						*te\syntaxHighlight()\style = #TE_Style_CodeMismatch
					Else
						If (*findToken\type = #TE_Token_BracketOpen) Or (*findToken\type = #TE_Token_BracketClose)
							*te\syntaxHighlight()\style = #TE_Style_BracketMatch
						Else
							*te\syntaxHighlight()\style = #TE_Style_CodeMatch
						EndIf
					EndIf
				EndIf
			EndIf
			
			If result = 0
				Repeat
					*token = #Null
					*te\parser\tokenIndex + direction
					
					If *te\parser\tokenIndex < 1
						*te\parser\textline = PreviousElement(*te\textLine())
						If *te\parser\textline And *te\textLine()\tokenCount
							*te\parser\tokenIndex = *te\textLine()\tokenCount
						EndIf
					ElseIf *te\parser\tokenIndex > *te\textLine()\tokenCount
						*te\parser\textline = NextElement(*te\textLine())
						If *te\parser\textline And *te\textLine()\tokenCount
							*te\parser\tokenIndex = 1
						EndIf						
					EndIf
					
					If *te\parser\textline And *te\parser\textline\tokenCount
						*token = @*te\parser\textline\token(*te\parser\tokenIndex)
						If *token
							If *te\parser\textline\style(*token\charNr) = #TE_Style_Comment
								*token = #Null
							ElseIf ((*token\type <> #TE_Token_Text) And (*token\type <> #TE_Token_BracketOpen) And (*token\type <> #TE_Token_BracketClose))
								*token = #Null
							EndIf
						EndIf
					EndIf
					
				Until *token Or (*te\parser\textline = #Null)
			EndIf
		Until (*token = #Null) Or result Or error
		
		ProcedureReturn result
	EndProcedure
	
	Procedure SyntaxHighlight_Start(*te.TE_STRUCT, *cursor.TE_CURSOR)
		ProcedureReturnIf((*te = #Null) Or (GetFlag(*te, #TE_EnableSyntaxHighlight) = 0) Or (*cursor = #Null) Or (*cursor\position\textline = #Null))
		
		Protected *token.TE_TOKEN, *testToken.TE_TOKEN
		Protected *found.TE_TOKEN
		Protected result1, result2
		Protected style, i
		Protected charNr = *cursor\position\charNr
		Protected key.s
		
		SyntaxHighlight_Clear(*te)
		
		If Style_FromCharNr(*cursor\position\textline, *cursor\position\charNr, #True) = #TE_Style_Comment
			ProcedureReturn #False
		EndIf
		
		Parser_Clear(*te\parser)
		
		For charNr = *cursor\position\charNr - 1 To *cursor\position\charNr
			*testToken = Parser_TokenAtCharNr(*te, *cursor\position\textline, charNr, #True)
			If *testToken And ((charNr = *cursor\position\charNr And *testToken\type = #TE_Token_Text) Or (*testToken\type = #TE_Token_BracketOpen) Or (*testToken\type = #TE_Token_BracketClose))
				key = LCase(TokenText(*testToken))
				If FindMapElement(*te\syntax(), key)
					*token = *testToken
					Break
				EndIf
			EndIf
		Next
		If *token = #Null
			ProcedureReturn
		EndIf
		
		*found = *token
		
		If (*te\syntax()\flags & #TE_Syntax_Break) Or (*te\syntax()\flags & #TE_Syntax_Continue)
			*found = SyntaxHighlight_Find(*te, -1, #TE_Syntax_Loop | #TE_Syntax_Start, #TE_Syntax_Loop | #TE_Syntax_End)
		ElseIf *te\syntax()\flags & #TE_Syntax_Return
			*found = SyntaxHighlight_Find(*te, -1, #TE_Syntax_Procedure | #TE_Syntax_Container | #TE_Syntax_Start, #TE_Syntax_Procedure | #TE_Syntax_Container | #TE_Syntax_End)
		EndIf
		
		If *found
			Protected parser.TE_PARSER
			
			CopyStructure(*te\parser, @parser, TE_PARSER)
			result1 = SyntaxHighlight_Check(*te, -1, #TE_Syntax_End, #TE_Syntax_Start, *te\syntax()\flags)
			
			CopyStructure(@parser, *te\parser, TE_PARSER)
			result2 = SyntaxHighlight_Check(*te, 1, #TE_Syntax_Start, #TE_Syntax_End, *te\syntax()\flags)
		EndIf
		
		If (*found = #Null) Or (result1 < 1) Or (result2 < 1)
			If AddElement(*te\syntaxHighlight())
				*te\syntaxHighlight()\textline = *cursor\position\textline
				*te\syntaxHighlight()\startCharNr = *token\charNr
				*te\syntaxHighlight()\endCharNr = *token\charNr + *token\size
				
				If *token\type = #TE_Token_BracketOpen Or *token\type = #TE_Token_BracketClose
					*te\syntaxHighlight()\style = #TE_Style_BracketMismatch
				Else
					*te\syntaxHighlight()\style = #TE_Style_CodeMismatch
				EndIf
			EndIf
		EndIf
		
		SyntaxHighlight_Update(*te)
		
		ProcedureReturn #True
	EndProcedure
	
	
	;-
	;- ----------- REPEATEDSELECTION -----------
	;-
	
	Procedure RepeatedSelection_Update(*te.TE_STRUCT, startLine, startCharNr, endLine, endCharNr)
		ProcedureReturnIf((*te = #Null) Or (startLine <> endLine) Or (startCharNr = endCharNr) Or (ListSize(*te\cursor()) > 1))
		
		Protected text.s = "", regExFlags = 0
		Protected range.TE_RANGE
		
		If startCharNr > endCharNr
			Swap startCharNr, endCharNr
		EndIf
		
		PushListPosition(*te\textLine())
		If Textline_FromLine(*te, startLine)
			If Parser_TokenAtCharNr(*te, Textline_FromLine(*te, startLine), startCharNr) = Parser_TokenAtCharNr(*te, Textline_FromLine(*te, endLine), endCharNr - 1)
				text = Text_Get(*te, startLine, startCharNr, endLine, endCharNr)
				
				If (*te\repeatedSelection\mode & #TE_RepeatedSelection_WholeWord)
					If Selection_WholeWord(*te, *te\currentCursor, startLine, startCharNr, @range)
						If (*te\repeatedSelection\minCharacterCount < 0) And (Abs(range\pos2\charNr - range\pos1\charNr) <> *te\parser\token\size)
							text = ""
						ElseIf Len(text) >= *te\repeatedSelection\minCharacterCount
							text = Text_Get(*te, range\pos1\lineNr, range\pos1\charNr, range\pos2\lineNr, range\pos2\charNr)
						ElseIf text <> TokenText(*te\parser\token)
							text = ""
						EndIf
						
					Else
						text = ""
					EndIf
				ElseIf (*te\repeatedSelection\minCharacterCount >= 0) And Len(text) < *te\repeatedSelection\minCharacterCount
					text = ""
				EndIf
			EndIf
		EndIf
		PopListPosition(*te\textLine())
		
		If (text = *te\commentChar) Or (Trim(Trim(text), #TAB$) = "")
			text = ""
		Else
			SyntaxHighlight_Clear(*te)
		EndIf
		If text = ""
			RepeatedSelection_Clear(*te)
		EndIf
		
		If *te\repeatedSelection\text <> text
			*te\repeatedSelection\text = text
			*te\repeatedSelection\textLen = Len(text)
			
			If IsRegularExpression(*te\regExRepeatedSelection)
				FreeRegularExpression(*te\regExRepeatedSelection)
			EndIf
			If text
				*te\redrawMode | #TE_Redraw_All
				If *te\repeatedSelection\mode & #TE_RepeatedSelection_NoCase
					regExFlags = #PB_RegularExpression_NoCase
				EndIf
				
				If *te\repeatedSelection\mode & #TE_RepeatedSelection_WholeWord
					text = ReplaceString(text, "\", "\\")
					text = ReplaceString(text, "*", "\*")
					text = ReplaceString(text, "$", "\$")
					text = ReplaceString(text, "#", "\#")
					text = ReplaceString(text, ".", "\.")
					text = ReplaceString(text, "(", "\(")
					text = ReplaceString(text, ")", "\)")
					If Left(text,1) = "\" And  Mid(text, Len(text) - 2, 1) = "\"
						*te\regExRepeatedSelection = CreateRegularExpression(#PB_Any, "\b(" + text + ")\b", regExFlags)	
					ElseIf Left(text,1) = "\"
						*te\regExRepeatedSelection = CreateRegularExpression(#PB_Any, "(" + text + ")\b", regExFlags)
					ElseIf Mid(text, Len(text) - 2, 1) = "\"
						*te\regExRepeatedSelection = CreateRegularExpression(#PB_Any, "\b(" + text + ")", regExFlags)
					Else
						*te\regExRepeatedSelection = CreateRegularExpression(#PB_Any, "(" + text + ")", regExFlags)
					EndIf
				Else
					*te\regExRepeatedSelection = CreateRegularExpression(#PB_Any, "(" + text + ")", regExFlags)
				EndIf
				ProcedureReturn #True
			EndIf
		EndIf
		
		ProcedureReturn #False
	EndProcedure
	
	Procedure RepeatedSelection_Clear(*te.TE_STRUCT)
		ProcedureReturnIf(*te = #Null)
		
		If *te\repeatedSelection\textLen
			*te\repeatedSelection\text = ""
			*te\repeatedSelection\textLen = 0
			*te\redrawMode | #TE_Redraw_All
		EndIf
	EndProcedure
	
	;-
	;- ----------- STYLE -----------
	;-
	
	Procedure Style_Textline(*te.TE_STRUCT, *textLine.TE_TEXTLINE, styleFlags = 0, *undo.TE_UNDO = #Null)
		ProcedureReturnIf((*te = #Null) Or (*textLine = #Null))
		
		Protected indentationCount, indentationBeforeCount, indentationAfterCount
		Protected foldCount, previousFoldCount
		Protected sSize, lastStyle
		Protected isComment.b = #False, isQuote.b = #False
		Protected *token.TE_TOKEN, *previousToken.TE_TOKEN, *lastNonWhitespaceToken.TE_TOKEN
		Protected charNr
		Protected i
		Protected tokenSize
		Protected tokenType
		Protected indentation
		Protected *keyWord.TE_KEYWORD
		Protected TokenText.s, key.s
		
		If Tokenizer_Textline(*te, *textLine)
			previousFoldCount = *textLine\foldCount
			
			sSize = Textline_Length(*textLine) + 1
			If (ArraySize(*textLine\style()) < sSize + 1) Or (ArraySize(*textLine\style()) > sSize + 32)
				ReDim *textLine\style(sSize + 1)
			EndIf
			FillMemory(@*textLine\style(), ArraySize(*textLine\style()), 0, #PB_Byte)
			
			If *textLine\remark
				*textLine\style(1) = #TE_Style_Text
				ProcedureReturn
			EndIf
			
			If GetFlag(*te, #TE_EnableStyling) = 0
				For i = 1 To *textLine\tokenCount
					*token.TE_TOKEN = @*textLine\token(i)
					*textLine\style(*token\charNr) = #TE_Style_None
				Next
				
				*textLine\needRedraw = #True
				ProcedureReturn
			EndIf
			
			For i = 1 To *textLine\tokenCount
				*token.TE_TOKEN = @*textLine\token(i)
				If *token
					tokenType = *token\type
					tokenSize = *token\size
					charNr = *token\charNr
					*keyWord = #Null
					
					If TokenType = #TE_Token_Comment
						isComment = #True
					ElseIf TokenType = #TE_Token_Uncomment
						isComment = #False
					EndIf
					
					If (isComment = #False) And (styleFlags & #TE_Styling_UpdateIndentation) And (*textLine\style(*token\charNr) <> #TE_Style_Comment)
						tokenText = PeekS(*token\text, *token\size)
						key = LCase(tokenText)
						*keyWord = FindMapElement(*te\keyWord(), key)
						If *keyWord
							If TokenType = #TE_Token_String Or TokenType = #TE_Token_Quote Or TokenType = #TE_Token_Comment
							ElseIf *previousToken And *previousToken\type = #TE_Token_Operator And *previousToken\text\c = '*'
							ElseIf *previousToken And *previousToken\type = #TE_Token_Unknown And *previousToken\text\c = '#'
							ElseIf *keyWord\indentationBefore Or *keyWord\indentationAfter
								indentationCount + 1
								If indentationCount = 1
									indentationBeforeCount = *keyWord\indentationBefore
									indentationAfterCount = *keyWord\indentationAfter
									indentation = indentationBeforeCount + indentationAfterCount
								Else
									indentation + *keyWord\indentationBefore
									indentationBeforeCount = Min(0, indentation)
									indentationAfterCount = *keyWord\indentationAfter + Max(0, indentation)
									indentation + *keyWord\indentationAfter
								EndIf
							EndIf
						EndIf
					EndIf
					
					If isComment
						
						*textLine\style(charNr) = #TE_Style_Comment
						
					Else
						
						Select tokenType
								
							Case #TE_Token_Text
								
								*textLine\style(charNr) = 0
								
								If tokenType = #TE_Token_Text And (i > 1)
									If i > 2 And *previousToken And *previousToken\type = #TE_Token_Colon And *textLine\token(i - 2)\type = #TE_Token_Text; And *textLine\style(i - 2) <> #TE_Style_Keyword
										If *textLine\style(*textLine\token(i - 2)\charNr) <> #TE_Style_Keyword
											*textLine\style(*textLine\token(i - 2)\charNr) = #TE_Style_Text
										EndIf
									ElseIf *previousToken And *previousToken\type = #TE_Token_Number
										*textLine\style(charNr) = #TE_Style_None
									ElseIf *previousToken And *previousToken\type = #TE_Token_Point
										*textLine\style(charNr) = #TE_Style_Structure
										; 									*token\type = #TE_Token_Unknown
									ElseIf *previousToken And *previousToken\type = #TE_Token_Operator And *previousToken\text\c = '*'
										*textLine\style(charNr) = #TE_Style_Pointer
										*textLine\style(*previousToken\charNr) = #TE_Style_Pointer
										; 									*token\type = #TE_Token_Unknown
									ElseIf *previousToken And *previousToken\type = #TE_Token_Unknown And *previousToken\text\c = '#'
										*textLine\style(charNr) = #TE_Style_Constant
										*textLine\style(*previousToken\charNr) = #TE_Style_Constant
										; 									*token\type = #TE_Token_Unknown
									ElseIf *lastNonWhitespaceToken And *lastNonWhitespaceToken\type = #TE_Token_Unknown And *lastNonWhitespaceToken\text\c = '@'
										*textLine\style(charNr) = #TE_Style_Address
										*textLine\style(*lastNonWhitespaceToken\charNr) = #TE_Style_Address
									ElseIf *lastNonWhitespaceToken And *lastNonWhitespaceToken\type = #TE_Token_Backslash
										*textLine\style(charNr) = #TE_Style_Text
										; 									*token\type = #TE_Token_Unknown
									EndIf
								EndIf
								
								If *textLine\style(charNr) = 0
									If *keyWord = 0
										TokenText = PeekS(*token\text, *token\size)
										key = LCase(TokenText)
										*keyWord = FindMapElement(*te\keyWord(), key)
									EndIf
									If *keyWord
										*textLine\style(charNr) = *keyWord\style
										foldCount + *keyWord\foldState
										
										If GetFlag(*te, #TE_EnableCaseCorrection) And (styleFlags & #TE_Styling_CaseCorrection) And (*keyWord\caseCorrection)
											Textline_ChangeText(*te, *textLine, charNr, *keyWord\name, *te\undo) 
										EndIf
										
									ElseIf tokenType = #TE_Token_Text
										*textLine\style(charNr) = #TE_Style_Text
									Else
										*textLine\style(charNr) = #TE_Style_Constant
									EndIf
									
								EndIf
								
							Case #TE_Token_String
								
								*textLine\style(charNr) = #TE_Style_String
								
							Case #TE_Token_Quote
								
								*textLine\style(charNr) = #TE_Style_Quote
								
							Case #TE_Token_Number
								
								*textLine\style(charNr) = #TE_Style_Number
								
							Case #TE_Token_Operator, #TE_Token_Equal, #TE_Token_Compare
								
								*textLine\style(charNr) = #TE_Style_Operator
								
							Case #TE_Token_Backslash
								
								*textLine\style(charNr) = #TE_Style_Backslash
								
							Case #TE_Token_BracketOpen
								
								*textLine\style(charNr) = #TE_Style_Bracket
								
								If *lastNonWhitespaceToken And (*lastNonWhitespaceToken\type = #TE_Token_Text) And (lastStyle <> #TE_Style_Keyword)
									*textLine\style(*lastNonWhitespaceToken\charNr) = #TE_Style_Function
								EndIf
								
							Case #TE_Token_BracketClose
								
								*textLine\style(charNr) = #TE_Style_Bracket
								
							Case #TE_Token_Comment
								
								*textLine\style(charNr) = #TE_Style_Comment
								
							Case #TE_Token_Uncomment
								
								*textLine\style(charNr) = #TE_Style_Comment
								
							Default
								
								*textLine\style(charNr) = #TE_Style_None
								
						EndSelect
						
						If TokenType = #TE_Token_Unknown
							If (*token\text\c = '$') And *previousToken And *previousToken\type = #TE_Token_Text
								*textLine\style(charNr) = #TE_Style_Text
							EndIf
						ElseIf TokenType = #TE_Token_Colon
							If (*previousToken And *previousToken\type = #TE_Token_Text) And (i >= *textLine\tokenCount Or *textLine\token(i + 1)\type <> #TE_Token_Colon)
								If *textLine\style(*previousToken\charNr) <> #TE_Style_Keyword
									*textLine\style(*previousToken\charNr) = #TE_Style_Label
								EndIf
							ElseIf (i > 2 And *textLine\token(i - 2)\type = #TE_Token_Text) And (*previousToken\type = #TE_Token_Colon)
								If *textLine\style(*textLine\token(i - 2)\charNr) <> #TE_Style_Keyword
									*textLine\style(*textLine\token(i - 2)\charNr) = #TE_Style_Structure
								EndIf
							EndIf
						EndIf
						
					EndIf
					
					If *lastNonWhitespaceToken
						If *lastNonWhitespaceToken\type = #TE_Token_Comment
							If styleFlags & #TE_Styling_UpdateFolding
								; hack for folding with ";{" and ";}" 
								If FindMapElement(*te\keyWord(), TokenText(*lastNonWhitespaceToken) + TokenText(*token))
									foldCount + *te\keyWord()\foldState
								EndIf
							EndIf
						EndIf
					EndIf
					
					*previousToken = *token
					If (tokenType <> #TE_Token_Whitespace)
						lastStyle = *textLine\style(charNr)
						*lastNonWhitespaceToken = *token
					EndIf
					
				EndIf
				
			Next
			
		EndIf
		
		If styleFlags & #TE_Styling_UnfoldIfNeeded
			If (*textLine\foldState = #TE_Folding_Folded) And (foldCount <= 0)
				styleFlags | #TE_Styling_UpdateFolding
			EndIf
		EndIf
		
		If styleFlags & #TE_Styling_UpdateFolding
			*textLine\foldCount = foldCount
			
			If (foldCount > 0) And (*textLine\foldState <= 0)
				*textLine\foldState = #TE_Folding_Unfolded
			ElseIf (foldCount < 0) And (*textLine\foldState >= 0)
				*textLine\foldState = #TE_Folding_End
			ElseIf (foldCount = 0) And (*textLine\foldState <> 0)
				*textLine\foldState = 0
			EndIf
			
			If foldCount <> previousFoldCount
				*te\needFoldUpdate = #True
			EndIf
		EndIf
		
		If styleFlags & #TE_Styling_UpdateIndentation
			*textLine\indentationBefore = indentationBeforeCount
			*textLine\indentationAfter = indentationAfterCount
		EndIf
		
		*textLine\needRedraw = #True
	EndProcedure
	
	Procedure Style_FromCharNr(*textLine.TE_TEXTLINE, charNr, scanWholeLine = #False)
		ProcedureReturnIf((*textLine = #Null) Or (ArraySize(*textLine\style()) < 1))
		
		Protected i
		Protected result = 0
		
		charNr = Clamp(charNr, 1, ArraySize(*textLine\style()))
		
		If scanWholeLine
			While (charNr > 0) And (result = 0)
				result = *textLine\style(charNr)
				charNr - 1
			Wend
		Else
			result = *textLine\style(charNr)
		EndIf
		
		ProcedureReturn result
	EndProcedure
	
	Procedure Style_LoadFont(*te.TE_STRUCT, *font.TE_FONT, fontName.s, fontSize, fontStyle = 0)
		ProcedureReturnIf((*te = #Null) Or (*font = #Null))
		
		Protected result = #False
		Protected c, minTextWidth, image
		
		If IsFont(*font\nr)
			FreeFont(*font\nr)
		EndIf
		
		CompilerSelect #PB_Compiler_OS
			CompilerCase #PB_OS_Windows
				*font\nr = LoadFont(#PB_Any, fontName, DesktopUnscaledY(fontSize) * 1.0, fontStyle)
			CompilerCase #PB_OS_MacOS
				*font\nr = LoadFont(#PB_Any, fontName, DesktopUnscaledY(fontSize) * 1.2, fontStyle)
			CompilerCase #PB_OS_Linux
				*font\nr = LoadFont(#PB_Any, fontName, DesktopUnscaledY(fontSize) * 1.0, fontStyle)
		CompilerEndSelect
		
		If IsFont(*font\nr)
			*font\style = fontStyle
			*font\id = FontID(*font\nr)
			*font\name = fontName
			*font\size = fontSize
			
			image = CreateImage(#PB_Any, 32, 32)
			If IsImage(image)
				If StartVectorDrawing(ImageVectorOutput(image))
					result = #True
					
					VectorFont(*font\id)
					
					minTextWidth = VectorTextWidth(" ")
					*font\height = VectorTextHeight(" ")
					*te\lineHeight = *font\height
					
					For c = 0 To #TE_CharRange
						*font\width(c) = Max(minTextWidth, VectorTextWidth(Chr(c)))
					Next
					*font\width(#TAB) = minTextWidth
					
					StopVectorDrawing()
				EndIf
				FreeImage(image)
			EndIf
		EndIf
		
		ProcedureReturn result
	EndProcedure
	
	Procedure Style_SetFont(*te.TE_STRUCT, fontName.s, fontSize, fontStyle = 0)
		ProcedureReturnIf((*te = #Null))
		
		Protected i, c, font
		fontSize = Clamp(fontSize, 1, *te\lineHeight)
		
		Style_LoadFont(*te, *te\font(#TE_Font_Normal), fontName, fontSize, #PB_Font_HighQuality | fontStyle)
		Style_LoadFont(*te, *te\font(#TE_Font_Bold), fontName, fontSize, #PB_Font_HighQuality | #PB_Font_Bold)
		; 		Style_LoadFont(*te, *te\font(#TE_Font_Italic), fontName, fontSize, #PB_Font_HighQuality | #PB_Font_Italic)
		; 		Style_LoadFont(*te, *te\font(#TE_Font_Underlined), fontName, fontSize, #PB_Font_HighQuality | #PB_Font_Underline)
		; 		Style_LoadFont(*te, *te\font(#TE_Font_StrikeOut), fontName, fontSize, #PB_Font_HighQuality | #PB_Font_StrikeOut)
		
		*te\leftBorderOffset = BorderSize(*te)
		
		ProcedureReturn #True
	EndProcedure
	
	Procedure Style_Set(*te.TE_STRUCT, styleNr, fontNr, fColor, bColor = #TE_Ignore, uColor = #TE_Ignore)
		ProcedureReturnIf((*te = #Null) Or (styleNr < 0) Or (styleNr > ArraySize(*te\textStyle())))
		
		With *te\textStyle(styleNr)
			\fColor = fColor
			\bColor = bColor
			\uColor = uColor
			\fontNr = fontNr
		EndWith
		
		ProcedureReturn #True
	EndProcedure
	
	Procedure Style_SetDefaultStyle(*te.TE_STRUCT)
		ProcedureReturnIf(*te = #Null)
		
		Style_Set(*te, #TE_Style_None, 0, *te\colors\defaultText)
		Style_Set(*te, #TE_Style_Keyword, 0, *te\colors\defaultText)
		Style_Set(*te, #TE_Style_Function, 0, *te\colors\defaultText)
		Style_Set(*te, #TE_Style_Structure, 0, *te\colors\defaultText)
		Style_Set(*te, #TE_Style_Text, 0, *te\colors\defaultText)
		Style_Set(*te, #TE_Style_String, 0, *te\colors\defaultText)
		Style_Set(*te, #TE_Style_Quote, 0, *te\colors\defaultText)
		Style_Set(*te, #TE_Style_Comment, 0, *te\colors\defaultText)
		Style_Set(*te, #TE_Style_Number, 0, *te\colors\defaultText)
		Style_Set(*te, #TE_Style_Pointer, 0, *te\colors\defaultText)
		Style_Set(*te, #TE_Style_Address, 0, *te\colors\defaultText)
		Style_Set(*te, #TE_Style_Constant, 0, *te\colors\defaultText)
		Style_Set(*te, #TE_Style_Operator, 0, *te\colors\defaultText)
		Style_Set(*te, #TE_Style_Backslash, 0, *te\colors\defaultText)
		Style_Set(*te, #TE_Style_Comma, 0, *te\colors\defaultText)
		Style_Set(*te, #TE_Style_Bracket, 0, *te\colors\defaultText)
		Style_Set(*te, #TE_Style_Label, 0, *te\colors\defaultText)
		Style_Set(*te, #TE_Style_CodeMatch, 1, RGBA(220, 135, 190, 255), RGBA( 85, 85, 80, 255), #True)
		Style_Set(*te, #TE_Style_CodeMismatch, 1, RGBA(255, 0, 0, 255), RGBA(130, 60, 20, 255), #True)
		Style_Set(*te, #TE_Style_BracketMatch, 0, RGBA(220, 135, 190, 255), RGBA( 85, 85, 80, 255))
		Style_Set(*te, #TE_Style_BracketMismatch, 0, RGBA(255, 0, 0, 255), RGBA(130, 60, 20, 255))
		
	EndProcedure
	
	;-
	;- ----------- TEXTLINE -----------
	;-
	
	Procedure Textline_Add(*te.TE_STRUCT)
		ProcedureReturnIf(*te = #Null)
		
		If AddElement(*te\textLine())
			*te\textLine()\text = ""
			*te\textLine()\lineNr = ListIndex(*te\textLine()) + 1
			*te\textLine()\needRedraw = #True
			*te\needFoldUpdate = #True
			ProcedureReturn *te\textLine()
		EndIf
		
		ProcedureReturn #Null
	EndProcedure
	
	Procedure Textline_Insert(*te.TE_STRUCT)
		ProcedureReturnIf(*te = #Null)
		
		If InsertElement(*te\textLine())
			*te\textLine()\text = ""
			*te\textLine()\lineNr = ListIndex(*te\textLine()) + 1
			*te\textLine()\needRedraw = #True
			*te\needFoldUpdate = #True
			ProcedureReturn *te\textLine()
		EndIf
		
		ProcedureReturn #Null
	EndProcedure
	
	Procedure Textline_Delete(*te.TE_STRUCT)
		ProcedureReturnIf((*te = #Null) Or (ListIndex(*te\textLine()) < 0))
		
		Protected *textline.TE_TEXTLINE
		Protected marker
		
		SyntaxHighlight_Clear(*te)
		
		*te\needFoldUpdate = #True
		
		marker = *te\textLine()\marker
		
		FreeArray(*te\textLine()\token())
		*te\textLine()\text = #Null$

		*textline = DeleteElement(*te\textLine(), 1)
		If *textline
			*textline\marker | marker
		EndIf
		
		If *te\currentCursor
			*te\currentCursor\previousPosition\textline = #Null
		EndIf

		ProcedureReturn *textline
	EndProcedure
	
	Procedure Textline_AddChar(*te.TE_STRUCT, *cursor.TE_CURSOR, c.c, overwrite, styleFlags = #TE_Styling_All, *undo.TE_UNDO = #Null)
		ProcedureReturnIf((*te = #Null) Or GetFlag(*te, #TE_EnableReadOnly) Or (*cursor = #Null) Or (*cursor\position\textline = #Null))
		ProcedureReturnIf(*cursor\position\textline\remark)
		
		ChangeCurrentElement(*te\textLine(), *cursor\position\textline)
		
		Protected *textLine.TE_TEXTLINE = *cursor\position\textline
		Protected *previousLine.TE_TEXTLINE
		Protected previousLineNr = *cursor\position\lineNr
		Protected previousCharNr = *cursor\position\charNr
		Protected marker
		
		CopyStructure(*cursor\position, *cursor\previousPosition, TE_POSITION)
		
		If c = *te\newLineChar
			ChangeCurrentElement(*te\textLine(), *textLine)
			
			*previousLine = *textLine
			*textLine = Textline_Add(*te)
			
			If *textLine
				*textLine\text = Mid(*previousLine\text, *cursor\position\charNr)
				*previousLine\text = Left(*previousLine\text, *cursor\position\charNr - 1)
				
				*cursor\position\textline = *textLine
				*cursor\position\lineNr + 1
				*cursor\position\visibleLineNr + 1
				*cursor\position\charNr = 1
				
				*cursor\position\charX = Textline_CharNrToScreenPos(*te, *cursor\position\textline, *cursor\position\charNr)
				*cursor\position\currentX = *cursor\position\charX
				
				If (*previousLine\marker) And (*textLine\text And *previousLine\text = "")
					Swap *textLine\marker, *previousLine\marker
				EndIf
				
				Style_Textline(*te, *previousLine, styleFlags, *undo)
			EndIf
			
		Else
			
			If overwrite And *cursor\position\charNr <= Textline_Length(*textLine)
				Undo_Add(*te, *undo, #TE_Undo_DeleteText, previousLineNr, previousCharNr, 0, 0, Mid(*textLine\text, *cursor\position\charNr, 1))
				*textLine\text = Text_Replace(*textLine\text, Chr(c), *cursor\position\charNr)
			Else
				*textLine\text = InsertString(*textLine\text, Chr(c), *cursor\position\charNr)
			EndIf
			*textLine\textWidth = Textline_Width(*te, *textLine)
			
			*cursor\position\charNr + 1
			*cursor\position\charX = Textline_CharNrToScreenPos(*te, *cursor\position\textline, *cursor\position\charNr)
			*cursor\position\currentX = *cursor\position\charX
			
			*te\cursorState\blinkSuspend = 1
			*te\maxTextWidth = Max(*te\maxTextWidth, *textLine\textWidth)
		EndIf
		
		*te\leftBorderOffset = BorderSize(*te)
		
		Undo_Add(*te, *undo, #TE_Undo_AddText, previousLineNr, previousCharNr, *cursor\position\lineNr, *cursor\position\charNr)
		
 		Style_Textline(*te, *cursor\position\textline, styleFlags, *undo)
		
		If overwrite = #False
			Cursor_MoveMulti(*te, *cursor, previousLineNr, *cursor\position\lineNr - previousLineNr, *cursor\position\charNr - previousCharNr)
		EndIf
		
		ProcedureReturn #True
	EndProcedure
	
	Procedure Textline_AddText(*te.TE_STRUCT, *cursor.TE_CURSOR, *c.Character, textLength, styleFlags = #TE_Styling_All, *undo.TE_UNDO = #Null)
		ProcedureReturnIf((*te = #Null) Or GetFlag(*te, #TE_EnableReadOnly) Or (*cursor = #Null) Or (*cursor\position\textline = #Null) Or (*c = #Null) Or (*c\c = 0))
		;ProcedureReturnIf(*cursor\position\textline\remark)
		
		; 		If textLength = 1
		; 			Cursor_Position(*te, *cursor, Textline_LineNr(*te, *cursor\position\textline), *cursor\position\charNr)
		; 			ProcedureReturn Textline_AddChar(*te, *cursor, *c\c, #False, styleFlags, *undo)
		; 		EndIf
		
		Protected previousLineNr = *cursor\position\lineNr
		Protected previousCharNr = *cursor\position\charNr
		Protected tail.s, text.s
		Protected *firstChar.Character = #Null
		Protected *previousLine.TE_TEXTLINE
		Protected addText, foldState
		
		CopyStructure(*cursor\position, *cursor\previousPosition, TE_POSITION)
		
		ChangeCurrentElement(*te\textLine(), *cursor\position\textline)
		
		tail = Mid(*cursor\position\textline\text, *cursor\position\charNr)
		*cursor\position\textline\text = Left(*cursor\position\textline\text, *cursor\position\charNr - 1)
		
		Repeat
			
			Select *c\c
				Case 0
					addText = -1
				Case *te\newLineChar
					addText = 1
				Case *te\foldChar
					foldState = #TE_Folding_Folded
				Case 9, 32 To #TE_CharRange
					If *firstChar = #Null
						*firstChar = *c
					EndIf
				Default
					addText = -2
			EndSelect
			
			If addText
				If *firstChar <> #Null
					text = PeekS(*firstChar, (*c - *firstChar) / #TE_CharSize)
					*cursor\position\textline\text + text
					*cursor\position\charNr + Len(text)
					*cursor\position\textline\foldState = foldState
					foldState = #TE_Folding_Unfolded
				EndIf
				
				If addText = 1
					*previousLine = *cursor\position\textline
					
					*cursor\position\textline\textWidth = Textline_Width(*te, *previousLine)
					*cursor\position\textline = Textline_Add(*te)
					*cursor\position\lineNr + 1
					*cursor\position\visibleLineNr + 1
					*cursor\position\charNr = 1
					*cursor\position\charX = 0
					
					*te\maxTextWidth = Max(*te\maxTextWidth, *previousLine\textWidth)
					
					Style_Textline(*te, *previousLine, styleFlags, *undo)
				EndIf
				
				*firstChar = #Null
				addText = 0
			EndIf
			
			If *c\c = 0
				Break
			EndIf
			
			*c + #TE_CharSize
		Until (addText = -1)
		
		*cursor\position\textline\text = *cursor\position\textline\text + tail
		*cursor\position\textline\textWidth = Textline_Width(*te, *cursor\position\textline)
		
		*te\maxTextWidth = Max(*te\maxTextWidth, *cursor\position\textline\textWidth)
		*te\leftBorderOffset = BorderSize(*te)
		*te\cursorState\blinkSuspend = 1
		*te\needDictionaryUpdate = #True
		
		Undo_Add(*te, *undo, #TE_Undo_AddText, previousLineNr, previousCharNr, *cursor\position\lineNr, *cursor\position\charNr)
		
		If styleFlags <> -1
 			Style_Textline(*te, *cursor\position\textline, styleFlags, *undo)
		EndIf
		
		Cursor_MoveMulti(*te, *cursor, previousLineNr, *cursor\position\lineNr - previousLineNr, *cursor\position\charNr - previousCharNr)
		
		ProcedureReturn #True
	EndProcedure
	
	Procedure Textline_ChangeText(*te.TE_STRUCT, *textline.TE_TEXTLINE, charNr, newText.s, *undo.TE_UNDO)
		ProcedureReturnIf((*te = #Null) Or (*textline = #Null) Or GetFlag(*te, #TE_EnableReadOnly))
		
		Protected oldText.s = Mid(*textline\text, charNr, Len(newText))
		If oldText <> newText
			Undo_Add(*te, *undo, #TE_Undo_ChangeText, *textline\lineNr, charNr, *te\currentCursor\previousPosition\lineNr, *te\currentCursor\previousPosition\charNr, oldText)
			ReplaceString(*textline\text, oldText, newText, #PB_String_InPlace, charNr, 1)
		EndIf
	EndProcedure
	
	Procedure Textline_SetText(*te.TE_STRUCT, *textLine.TE_TEXTLINE, text.s, styleFlags = #TE_Styling_All, *undo.TE_UNDO = #Null)
		ProcedureReturnIf((*te = #Null) Or (*textLine = #Null) Or (*textLine\text = text))
		
		Protected lineNr = Textline_LineNr(*te, *textLine)
		
		Undo_Add(*te, *undo, #TE_Undo_DeleteText, lineNr, 1, 0, 0, *textLine\text)
		Undo_Add(*te, *undo, #TE_Undo_AddText, lineNr, 1, lineNr, Len(text) + 1)
		
		*textLine\text = text
		
		Style_Textline(*te, *textLine, styleFlags, *undo)
		
		ProcedureReturn #True
	EndProcedure
	
	Procedure.s Textline_GetText(*te.TE_STRUCT, lineNr)
		ProcedureReturnIf(*te = #Null, "")
		
		Protected text.s = ""
		PushListPosition(*te\textLine())
		If Textline_FromLine(*te, lineNr)
			text = *te\textLine()\text
		EndIf
		PopListPosition(*te\textLine())
		
		ProcedureReturn text
	EndProcedure
	
	Procedure Textline_AddRemark(*te.TE_STRUCT, lineNr, type , text.s, *undo.TE_UNDO)
		ProcedureReturnIf(*te = #Null)
		
 		Cursor_Position(*te, *te\currentCursor, lineNr, 1)
		If SelectElement(*te\textLine(), Max(0, lineNr - 1))
			If Textline_Insert(*te)
				*te\textLine()\text = text
				*te\textLine()\remark = type
				Style_Textline(*te, *te\textLine())
				Undo_Add(*te, *undo, #TE_Undo_AddRemark, ListIndex(*te\textLine()), type)
			EndIf
		EndIf
	EndProcedure
	
	Procedure Textline_DeleteRemark(*te.TE_STRUCT, lineNr, *undo.TE_UNDO)
		ProcedureReturnIf(*te = #Null)
		
 		Cursor_Position(*te, *te\currentCursor, lineNr, 1)
		If SelectElement(*te\textLine(), lineNr)
			Undo_Add(*te, *undo, #TE_Undo_DeleteRemark, ListIndex(*te\textLine()), *te\textLine()\remark, 0, 0, *te\textLine()\text)
			ProcedureReturn Textline_Delete(*te)
		EndIf
		
		ProcedureReturn #Null
	EndProcedure
	
	Procedure TextLine_IsEmpty(*textline.TE_TEXTLINE)
		ProcedureReturnIf(*textline = #Null)
		
		If (*textline\tokenCount = 1) And (*textline\token(1)\type = #TE_Token_EOL)
			ProcedureReturn #True
		ElseIf (*textline\tokenCount = 2) And (*textline\token(1)\type = #TE_Token_Whitespace)
			ProcedureReturn #True
		EndIf
		
		ProcedureReturn #False
	EndProcedure
	
	Procedure Textline_LineNr(*te.TE_STRUCT, *textline.TE_TEXTLINE)
		ProcedureReturnIf((*te = #Null) Or (*textline = #Null))
		
		Protected lineNr
		
		PushListPosition(*te\textLine())
		ChangeCurrentElement(*te\textLine(), *textline)
		lineNr = ListIndex(*te\textLine()) + 1
		PopListPosition(*te\textLine())
		
		ProcedureReturn lineNr
	EndProcedure
	
	Procedure Textline_FromLine(*te.TE_STRUCT, lineNr)
		ProcedureReturnIf((*te = #Null) Or (ListSize(*te\textLine()) = 0))
		
		lineNr = Clamp(lineNr, 1, ListSize(*te\textLine()))
		
		If SelectElement(*te\textLine(), lineNr - 1)
			ProcedureReturn *te\textLine()
		EndIf
		
		ProcedureReturn #Null
	EndProcedure
	
	Procedure Textline_FromVisibleLineNr(*te.TE_STRUCT, visibleLineNr)
		ProcedureReturnIf((*te = #Null) Or (ListSize(*te\textLine()) = 0))
		
		Protected lineNr = LineNr_from_VisibleLineNr(*te, visibleLineNr)
		
		If SelectElement(*te\textLine(), lineNr - 1)
			ProcedureReturn *te\textLine()
		EndIf
		
		ProcedureReturn #Null
	EndProcedure
	
	Procedure Textline_TopLine(*te.TE_STRUCT)
		ProcedureReturnIf(*te = #Null)
		
		ProcedureReturn LineNr_from_VisibleLineNr(*te, *te\currentView\scroll\visibleLineNr)
	EndProcedure
	
	Procedure Textline_BottomLine(*te.TE_STRUCT)
		ProcedureReturnIf(*te = #Null)
		
		ProcedureReturn Min(LineNr_from_VisibleLineNr(*te, *te\currentView\scroll\visibleLineNr + *te\currentView\pageHeight + 1), ListSize(*te\textLine()))
	EndProcedure
	
	Procedure Textline_LineNrFromScreenPos(*te.TE_STRUCT, *view.TE_VIEW, screenY)
		ProcedureReturnIf((*te = #Null) Or (*view = #Null) Or (*te\lineHeight = 0))
		
		Protected lineNr
		
		screenY = Clamp(screenY, 0, *view\height - 1)
		
		lineNr = LineNr_from_VisibleLineNr(*te, *view\scroll\visibleLineNr + (screenY - *te\topBorderSize) / *te\lineHeight)
		
		ProcedureReturn Clamp(lineNr, 1, ListSize(*te\textLine()))
	EndProcedure
	
	Procedure Textline_CharNrFromScreenPos(*te.TE_STRUCT, *textLine.TE_TEXTLINE, screenX)
		ProcedureReturnIf((*te = #Null) Or (*textLine = #Null))
		
		Protected *font.TE_FONT, fontNr
		Protected *t.Character
		Protected x, width, tabWidth
		Protected style
		Protected charNr
		
		*t = @*textLine\text
		x = 0
		
		If screenX <= 0
			ProcedureReturn 1
		ElseIf *t
			charNr = 1
			*font = @*te\font(#TE_Font_Normal)
			
			If *te\useRealTab
				tabWidth = (*font\width(#TAB) * *te\tabSize)
			Else
				tabWidth = (*font\width(' ') * *te\tabSize)
			EndIf
			
			If tabWidth < 1
				tabWidth = 1
			EndIf
			
			While *t\c
				style = Style_FromCharNr(*textLine, charNr)
				If style
					fontNr = Clamp(*te\textStyle(style)\fontNr, 0, ArraySize(*te\font()))
					*font = @*te\font(fontNr)
				EndIf
				
				Select *t\c
					Case #TAB
						width = tabWidth - ( (x + tabWidth) % tabWidth)
					Default
						width = *font\width(*t\c)
				EndSelect
				
				If (screenX > x) And (screenX <= (x + width * 0.5))
					ProcedureReturn charNr
				ElseIf (screenX > x + width * 0.5) And (screenX <= (x + width))
					ProcedureReturn charNr + 1
				EndIf
				
				x + width
				charNr + 1
				*t + #TE_CharSize
			Wend
		EndIf
		
		ProcedureReturn Textline_Length(*textLine) + 1
	EndProcedure
	
	Procedure Textline_ColumnFromCharNr(*te.TE_STRUCT, *view.TE_VIEW, *textLine.TE_TEXTLINE, charNr)
		ProcedureReturnIf((*te = #Null) Or (*view = #Null) Or (*textLine = #Null)); Or (*textLine\text = ""))
		
		Protected *font.TE_FONT, fontNr
		Protected *t.Character
		Protected x, width, tabWidth, currentCharNr
		Protected style
		Protected column, nextColumn
		
		*t = @*textLine\text
		
		If charNr <= 1
			ProcedureReturn 1
		ElseIf *t
			currentCharNr = 1
			column = 1
			x = *view\scroll\charX
			*font = @*te\font(#TE_Font_Normal)
			
			If *te\useRealTab
				tabWidth = (*font\width(#TAB) * *te\tabSize)
			Else
				tabWidth = (*font\width(' ') * *te\tabSize)
			EndIf
			
			If tabWidth < 1
				tabWidth = 1
			EndIf
			
			While *t\c
				style = Style_FromCharNr(*textLine, column)
				If style
					fontNr = Clamp(*te\textStyle(style)\fontNr, 0, ArraySize(*te\font()))
					*font = @*te\font(fontNr)
				EndIf
				
				Select *t\c
					Case #TAB
						width = tabWidth - ( (x + tabWidth) % tabWidth)
						nextColumn = column + (width / *font\width(#TAB))
					Default
						width = *font\width(*t\c)
						nextColumn = column + 1
				EndSelect
				
				If charNr = currentCharNr
					ProcedureReturn column
				EndIf
				
				column = nextColumn
				currentCharNr + 1
				x + width
				*t + #TE_CharSize
			Wend
		EndIf
		
		ProcedureReturn column
	EndProcedure
	
	Procedure Textline_CharNrToScreenPos(*te.TE_STRUCT, *textLine.TE_TEXTLINE, charNr)
		ProcedureReturnIf((*te = #Null) Or (*textLine = #Null) Or (charNr < 1))
		
		Protected *font.TE_FONT, fontNr
		Protected *t.Character
		Protected x, tabWidth, cNr
		Protected style
		Protected maxX
		
		*t = @*textLine\text
		If *t
			cNr = 1
			*font = @*te\font(#TE_Font_Normal)
			
			If *te\useRealTab
				tabWidth = Max(1, *font\width(#TAB) * *te\tabSize)
			Else
				tabWidth = Max(1, *font\width(' ') * *te\tabSize)
			EndIf
			
			While *t\c And (cNr < charNr)
				style = Style_FromCharNr(*textLine, cNr)
				If style
					fontNr = Clamp(*te\textStyle(style)\fontNr, 0, ArraySize(*te\font()))
					*font = @*te\font(fontNr)
				EndIf
				
				Select *t\c
					Case #TAB
						x + tabWidth - ( (x + tabWidth) % tabWidth)
					Case 0 To #TE_CharRange
						x + *font\width(*t\c)
				EndSelect
				
				cNr + 1
				*t + #TE_CharSize
			Wend
		EndIf
		
		ProcedureReturn x
	EndProcedure
	
	Procedure Textline_CharAtPos(*textline.TE_TEXTLINE, charNr)
		ProcedureReturnIf((*textline = #Null) Or (charNr < 1) Or (charNr > Textline_Length(*textline)))
		
		ProcedureReturn Asc(Mid(*textline\text, charNr, 1))
	EndProcedure
	
	
	Procedure Textline_Width(*te.TE_STRUCT, *textLine.TE_TEXTLINE)
		ProcedureReturnIf((*te = #Null) Or (*textLine = #Null))
		
		ProcedureReturn Textline_CharNrToScreenPos(*te, *textLine, Textline_Length(*textLine) + 1)
	EndProcedure
	
	Procedure Textline_Start(*textline.TE_TEXTLINE, charNr)
		ProcedureReturnIf(*textLine = #Null)
		
		If *textline\tokenCount
			If (*textline\token(1)\type = #TE_Token_Whitespace) And (charNr <> *textline\token(1)\size + 1)
				ProcedureReturn *textline\token(1)\size + 1
			EndIf
		EndIf
		ProcedureReturn 1
	EndProcedure
	
	Procedure Textline_Length(*textLine.TE_TEXTLINE)
		ProcedureReturnIf(*textLine = #Null)
		
		ProcedureReturn Len(*textLine\text)
	EndProcedure
	
	Procedure Textline_LastCharNr(*te.TE_STRUCT, lineNr)
		ProcedureReturnIf(*te = #Null)
		
		If Textline_FromLine(*te, lineNr)
			ProcedureReturn Len(*te\textLine()\text) + 2
		EndIf
		
		ProcedureReturn 0
	EndProcedure
	
	Procedure Textline_NextTabSize(*te.TE_STRUCT, *textline.TE_TEXTLINE, charNr)
		ProcedureReturnIf((*te = #Null) Or (*textline = #Null) Or (*te\font(#TE_Font_Normal)\width(#TAB) = 0))
		
		Protected x, tabWidth
		
		x = Textline_CharNrToScreenPos(*te, *textline, charNr)
		tabWidth = Max(1, *te\font(#TE_Font_Normal)\width(' ') * *te\tabSize)
		tabWidth = Max(1, tabWidth - ( (x + tabWidth) % tabWidth))
		
		; 		ProcedureReturn charNr + (tabWidth / *te\font(#TE_Font_Normal)\width(#TAB))
		ProcedureReturn tabWidth / *te\font(#TE_Font_Normal)\width(#TAB)
	EndProcedure
	
	Procedure Textline_JoinNextLine(*te.TE_STRUCT, *cursor.TE_CURSOR, *undo.TE_UNDO)
		ProcedureReturnIf((*te = #Null) Or (*cursor = #Null) Or (*cursor\position\textline = #Null))
		
		Protected lineNr = *cursor\position\lineNr
		Protected charNr = *cursor\position\charNr

		Protected *textblock.TE_TEXTBLOCK = Folding_GetTextBlock(*te, *cursor\position\lineNr)
		If *textblock And (*textblock\firstLine\foldState & #TE_Folding_Folded)
			Folding_UnfoldTextline(*te, *textblock\firstLineNr)
		EndIf
		
		If *cursor\position\charNr > Textline_Length(*cursor\position\textline)
			Cursor_Position(*te, *cursor, lineNr + 1, 1, #True, #True, *undo)
			Selection_SetRange(*te, *cursor, lineNr, charNr)
			ProcedureReturn Selection_Delete(*te, *cursor, *undo)
		EndIf
		
		ProcedureReturn #False
	EndProcedure
	
	Procedure Textline_JoinPreviousLine(*te.TE_STRUCT, *cursor.TE_CURSOR, *textLine.TE_TEXTLINE, *undo.TE_UNDO)
		ProcedureReturnIf((*te = #Null) Or (*cursor = #Null) Or (*cursor\position\textline = #Null))
		
		Protected lineNr = *cursor\position\lineNr
		
		If *cursor\position\charNr <= 1
			If Cursor_Move(*te, *cursor, 0, -1)
				Protected *textblock.TE_TEXTBLOCK = Folding_GetTextBlock(*te, *cursor\position\lineNr)
				If *textblock And (*textblock\firstLine\foldState & #TE_Folding_Folded)
					Folding_UnfoldTextline(*te, *textblock\firstLineNr)
					If lineNr > *textblock\lastLineNr
						Cursor_Position(*te, *cursor, *textblock\lastLineNr, Textline_LastCharNr(*te, *textblock\lastLineNr), #True, #True, *undo) 
					EndIf
				EndIf
				ProcedureReturn Textline_JoinNextLine(*te, *cursor, *undo)
			EndIf
		EndIf
		
		ProcedureReturn #False
	EndProcedure
	
	
	Procedure Textline_FindText(*textline.TE_TEXTLINE, find.s, *result.TE_RANGE, ignoreWhiteSpace = #False)
		ProcedureReturnIf((*textline = #Null) Or (*result = #Null) Or (find = ""))
		
		*result\pos1\charNr = 0
		*result\pos2\charNr = 0
		
		Protected *text.Character = @*textline\text
		Protected *find.Character = @find
		Protected findLength = Len(find)
		Protected matchLength
		
		If findLength > Textline_Length(*textline)
			ProcedureReturn #False
		EndIf
		
		If ignoreWhiteSpace
			While (*text\c = ' ') Or (*text\c = #TAB)
				*text + #TE_CharSize
			Wend
		EndIf
		
		While *find\c And *text\c
			If *text\c <> *find\c
				ProcedureReturn #False
			EndIf
			
			matchLength + 1
			
			If *result\pos1\charNr = 0
				*result\pos1\charNr = (*text - @*textline\text) / #TE_CharSize + 1
			EndIf
			If matchLength = findLength
				*result\pos2\charNr = (*text - @*textline\text) / #TE_CharSize + 2
				ProcedureReturn #True
			EndIf
			
			*find + #TE_CharSize
			*text + #TE_CharSize
		Wend
		
		ProcedureReturn #False
	EndProcedure
	
	Procedure Textline_HasLineContinuation(*te.TE_STRUCT, *textline.TE_TEXTLINE)
		ProcedureReturnIf((*te = #Null) Or (*textline = #Null) Or (*textline\tokenCount < 1))
		Protected lastToken = *textline\tokenCount
		Protected key.s
		
		; strip trailing whitespace and comment
		While (lastToken > 0) And ((*textline\token(lastToken)\type = #TE_Token_EOL) Or (*textline\token(lastToken)\type = #TE_Token_Whitespace) Or (*textline\token(lastToken)\type = #TE_Token_Comment))
			lastToken - 1
		Wend
		
		If lastToken > 0
			key = LCase(TokenText(*textline\token(lastToken)))
			ProcedureReturn FindMapElement(*te\keyWordLineContinuation(), key)
		EndIf
		ProcedureReturn 0
	EndProcedure
	
	Procedure TestTokenPair(*token1.TE_TOKEN, *token2.TE_TOKEN, type1, type2, flags = 1, bothWays = #False)
		ProcedureReturnIf(*token1 = #Null Or *token2 = #Null)
		
		Protected test1, test2
		If type1 < 0
			test1 = Bool(*token1\type <> -type1)
		Else
			test1 = Bool(*token1\type = type1)
		EndIf
		If type2 < 0
			test2 = Bool(*token2\type <> -type2)
		Else
			test2 = Bool(*token2\type = type2)
		EndIf	
		If test1 And test2
			ProcedureReturn flags
		ElseIf bothWays
			ProcedureReturn TestTokenPair(*token2, *token1, type1, type2, flags)
		EndIf
		
		ProcedureReturn 0
	EndProcedure
	
	Procedure Textline_Beautify(*te.TE_STRUCT, *textline.TE_TEXTLINE)
		ProcedureReturnIf((*te = #Null) Or (*textline = #Null) Or (*textline\tokenCount < 1))
		ProcedureReturnIf(GetFlag(*te, #TE_EnableBeautify) = 0)
		
		Protected lastBracket, currentBracket
		Protected *last.TE_TOKEN, *last2.TE_TOKEN, *current.TE_TOKEN
		Protected text.s
		Protected i, isVal = -1, lastIsVal = -1, lastIsVal2 = -1
		Protected style, isComment = #False
		
		Dim token.s(*textline\tokenCount)
		Dim style.i(*textline\tokenCount)
		
		For i = 1 To *textline\tokenCount
			If *textline\token(i)\type = #TE_Token_Comment
				isComment = #True
			ElseIf *textline\token(i)\type = #TE_Token_Uncomment
				isComment = #False
			EndIf
			
			If (isComment = #False) And (*textline\token(i)\type = #TE_Token_Whitespace)
				If i = *textline\tokenCount - 1
					token(i) = ""
				Else
					token(i) = " "
				EndIf
			Else
				token(i) = TokenText(*textline\token(i))
			EndIf
			style(i) = Style_FromCharNr(*textline, *textline\token(i)\charNr)
		Next
		
		EnumerationBinary
			#AddSpaceBefore
			#AddSpaceAfter
			#DeleteSpaceBefore
			#DeleteSpaceAfter
		EndEnumeration
		
		Protected.TE_TOKEN *token1, *token2, *token3.TE_TOKEN, *lastNonWhite
		Protected flags
		
		isComment = #False
		
		For i = 2 To *textline\tokenCount - 1
			*token1 = *textline\token(i - 1)
			*token2 = *textline\token(i)
			*token3 = *textline\token(i + 1)
			flags = 0
			;a=-2
			
			If *token1
				If *token1\type = #TE_Token_Comment
					isComment = #True
				ElseIf *token1\type = #TE_Token_Uncomment
					isComment = #False
				EndIf
			EndIf
			
			If (isComment = #False) And *token1 And *token2 And *token3
				
				If (*lastNonWhite And (*lastNonWhite\type = #TE_Token_Number Or *lastNonWhite\type = #TE_Token_Text Or *lastNonWhite\type = #TE_Token_Unknown Or *lastNonWhite\type = #TE_Token_Operator) And *lastNonWhite\text\c <> '-')  Or token(i - 1) <> "-"
					flags | TestTokenPair(*token1, *token2, #TE_Token_Operator, -#TE_Token_Whitespace, #AddSpaceBefore, #True)
				EndIf
				If (*lastNonWhite And (*lastNonWhite\type = #TE_Token_Number Or *lastNonWhite\type = #TE_Token_Text Or *lastNonWhite\type = #TE_Token_Unknown Or *lastNonWhite\type = #TE_Token_Operator)  And *lastNonWhite\text\c <> '-') Or token(i - 1) <> "-"
					flags | TestTokenPair(*token1, *token2, -#TE_Token_Whitespace, #TE_Token_Operator, #AddSpaceAfter, #True)
				EndIf
				If TestTokenPair(*token1, *token2, #TE_Token_Equal, #TE_Token_Compare, 1, #True) = 0
					If TestTokenPair(*token1, *token2, #TE_Token_Compare, #TE_Token_Compare) = 0
						flags | TestTokenPair(*token1, *token2, #TE_Token_Compare, -#TE_Token_Whitespace, #AddSpaceBefore, #True)
					EndIf
				EndIf
				If TestTokenPair(*token1, *token2, #TE_Token_Colon, -#TE_Token_Colon, 1, #True) And TestTokenPair(*token2, *token3, #TE_Token_Colon, #TE_Token_Colon) = 0
					flags | TestTokenPair(*token1, *token2, #TE_Token_Colon, -#TE_Token_Whitespace, #AddSpaceBefore, #True)
				EndIf
				If style(i - 1) = #TE_Style_Text
					flags | TestTokenPair(*token2, *token3, #TE_Token_Whitespace, #TE_Token_Backslash, #DeleteSpaceAfter)
				EndIf
				If TestTokenPair(*token1, *token2, #TE_Token_Equal, #TE_Token_Compare, 1, #True) = 0
					flags | TestTokenPair(*token1, *token2, #TE_Token_Equal, -#TE_Token_Whitespace, #AddSpaceAfter, #True)
				EndIf
				If (*token1\type = #TE_Token_Compare Or *token1\type = #TE_Token_Equal) And (*token2\type = #TE_Token_Whitespace) And (*token3\type = #TE_Token_Compare Or *token3\type = #TE_Token_Equal)
					flags | #DeleteSpaceAfter
				EndIf
				flags | TestTokenPair(*token1, *token2, #TE_Token_Backslash, #TE_Token_Whitespace, #DeleteSpaceAfter)
				flags | TestTokenPair(*token1, *token2, #TE_Token_Backslash, #TE_Token_Whitespace, #DeleteSpaceAfter)
				flags | TestTokenPair(*token1, *token2, #TE_Token_BracketOpen, #TE_Token_Whitespace, #DeleteSpaceAfter)
				flags | TestTokenPair(*token1, *token2, #TE_Token_BracketClose, -#TE_Token_Whitespace, #AddSpaceBefore)
				flags | TestTokenPair(*token1, *token2, #TE_Token_Whitespace, #TE_Token_BracketClose, #DeleteSpaceBefore)
				; 				flags | TestTokenPair(*token1, *token2, #TE_Token_Whitespace, #TE_Token_BracketOpen, #DeleteSpaceBefore)
				flags | TestTokenPair(*token1, *token2, #TE_Token_Whitespace, #TE_Token_Point, #DeleteSpaceBefore)
				flags | TestTokenPair(*token1, *token2, #TE_Token_Point, #TE_Token_Whitespace, #DeleteSpaceAfter)
				flags | TestTokenPair(*token1, *token2, #TE_Token_Comma, -#TE_Token_Whitespace, #AddSpaceBefore)
				flags | TestTokenPair(*token1, *token2, #TE_Token_Whitespace, #TE_Token_Comma, #DeleteSpaceBefore)
				
				If flags & #DeleteSpaceBefore
					token(i - 1) = ""
				ElseIf flags & #AddSpaceBefore And style(i - 1) <> #TE_Style_Pointer And style(i - 1) <> #TE_Style_Bracket
					token(i - 1) = RTrim(token(i - 1)) + " "
				ElseIf flags & #DeleteSpaceAfter
					token(i) = ""
				ElseIf flags & #AddSpaceAfter And style(i) <> #TE_Style_Pointer And style(i) <> #TE_Style_Bracket
					token(i) = " " + LTrim(token(i))
				EndIf
			EndIf
			If *token1\type <> #TE_Token_Whitespace
				*lastNonWhite = *token1
			EndIf
		Next
		
		For i = 1 To *textline\tokenCount
			text + token(i)
		Next
		
		ProcedureReturn Textline_SetText(*te, *textline, text, #TE_Styling_UpdateIndentation | #TE_Styling_UpdateFolding | #TE_Styling_CaseCorrection, *te\undo)
	EndProcedure
	
	;-
	;- ----------- SELECTION -----------
	;-
	
	Procedure Selection_Get(*cursor.TE_CURSOR, *range.TE_RANGE)
		ProcedureReturnIf((*cursor = #Null) Or (*range = #Null), #False)
		
		; return the selection of *cursor
		;
		; *range\pos1 = top position of selection
		; *range\pos2 = bottom position of selection
		
		If (*cursor\selection\lineNr < 1) Or ( (*cursor\position\lineNr = *cursor\selection\lineNr) And (*cursor\position\charNr = *cursor\selection\charNr))
			*range\pos1\lineNr = *cursor\position\lineNr
			*range\pos1\charNr = *cursor\position\charNr
			*range\pos2\lineNr = *cursor\position\lineNr
			*range\pos2\charNr = *cursor\position\charNr
			ProcedureReturn #False
		ElseIf (*cursor\position\lineNr < *cursor\selection\lineNr) Or (*cursor\position\lineNr = *cursor\selection\lineNr And *cursor\position\charNr < *cursor\selection\charNr)
			*range\pos1\lineNr = *cursor\position\lineNr
			*range\pos1\charNr = *cursor\position\charNr
			*range\pos2\lineNr = *cursor\selection\lineNr
			*range\pos2\charNr = *cursor\selection\charNr
		Else
			*range\pos1\lineNr = *cursor\selection\lineNr
			*range\pos1\charNr = *cursor\selection\charNr
			*range\pos2\lineNr = *cursor\position\lineNr
			*range\pos2\charNr = *cursor\position\charNr
		EndIf
		
		ProcedureReturn #True
	EndProcedure
	
	Procedure Selection_GetAll(*te.TE_STRUCT, *range.TE_RANGE, clearRange = #True)
		ProcedureReturnIf((*te = #Null) Or (*range = #Null))
		
		; return the min / max lineNr and charNr of multicursor selections
		
		Protected selection.TE_RANGE
		
		If clearRange
			ClearStructure(*range, TE_RANGE)
		EndIf
		
		PushListPosition(*te\cursor())
		If FirstElement(*te\cursor())
			*range\pos1\lineNr = *te\cursor()\position\lineNr
			*range\pos1\charNr = *te\cursor()\position\charNr
			*range\pos2\lineNr = *te\cursor()\position\lineNr
			*range\pos2\charNr = *te\cursor()\position\charNr
			Repeat
				Selection_Get(*te\cursor(), selection)
				Selection_Add(*range, selection\pos1\lineNr, selection\pos1\charNr)
				Selection_Add(*range, selection\pos2\lineNr, selection\pos2\charNr)
			Until NextElement(*te\cursor()) = #Null
		EndIf
		PopListPosition(*te\cursor())
	EndProcedure
	
	Procedure Selection_Start(*cursor.TE_CURSOR, lineNr, charNr, startSelection = -1)
		ProcedureReturnIf((*cursor = #Null) Or (startSelection = 0) Or (startSelection > 0 And Cursor_HasSelection(*cursor)))
		
		*cursor\selection\lineNr = lineNr
		*cursor\selection\charNr = charNr
	EndProcedure
	
	Procedure Selection_Delete(*te.TE_STRUCT, *cursor.TE_CURSOR, *undo.TE_UNDO = #Null)
		ProcedureReturnIf((*te = #Null) Or GetFlag(*te, #TE_EnableReadOnly) Or (*cursor = #Null))

		Protected result = #False
		Protected text.s
		Protected previousLineNr
		Protected selection.TE_RANGE
		Protected nrLines
		Protected *textLine.TE_TEXTLINE
		
		If Selection_Get(*cursor, selection) = #False
			ProcedureReturn #False
		EndIf
		
		If Remark_IsSelected(*te, selection\pos1\lineNr, selection\pos2\lineNr)
			ProcedureReturn #False
		EndIf
		
		nrLines = (selection\pos2\lineNr - selection\pos1\lineNr) + 1
		
		If (nrLines < 1) Or Textline_FromLine(*te, selection\pos1\lineNr) = #Null
			ProcedureReturn #False
		EndIf
		
		If *cursor\position\lineNr >= *cursor\selection\lineNr
			previousLineNr = *cursor\position\lineNr
		Else
			previousLineNr = *cursor\selection\lineNr
		EndIf
		
		Undo_Add(*te, *undo, #TE_Undo_DeleteText, selection\pos1\lineNr, selection\pos1\charNr, 0, 0, Text_Get(*te, selection\pos1\lineNr, selection\pos1\charNr, selection\pos2\lineNr, selection\pos2\charNr))

		If nrLines = 1
			*te\textLine()\text = Text_Cut(*te\textLine()\text, selection\pos1\charNr, selection\pos2\charNr - selection\pos1\charNr)
		ElseIf nrLines = 2
			text = Left(*te\textLine()\text, selection\pos1\charNr - 1)
			If NextElement(*te\textLine())
				text + Mid(*te\textLine()\text, selection\pos2\charNr)
				Textline_Delete(*te)
				*te\textLine()\text = text
			EndIf
		ElseIf nrLines > 2
			text = Left(*te\textLine()\text, selection\pos1\charNr - 1)
			While (nrLines > 2) And NextElement(*te\textLine())
				Textline_Delete(*te)
				nrLines - 1
			Wend
			If NextElement(*te\textLine())
				text + Mid(*te\textLine()\text, selection\pos2\charNr)
				Textline_Delete(*te)
			EndIf
			
			*te\textLine()\text = text
		EndIf
		
		*te\leftBorderOffset = BorderSize(*te)
		
		Style_Textline(*te, *te\textLine(), #TE_Styling_UpdateFolding | #TE_Styling_UpdateIndentation, *undo)
		
		*cursor\position\textline = *te\textLine()
		*cursor\position\lineNr = ListIndex(*te\textLine()) + 1
		*cursor\position\visibleLineNr = LineNr_to_VisibleLineNr(*te, *cursor\position\lineNr)
		*cursor\position\charNr = selection\pos1\charNr
		*cursor\position\textline\needStyling = #True
		
		*te\cursorState\blinkSuspend = 1
		*te\needDictionaryUpdate = #True
		
		; 		*cursor\position\textline\needStyling = #True
		
		Cursor_MoveMulti(*te, *cursor, previousLineNr, selection\pos1\lineNr - selection\pos2\lineNr, selection\pos1\charNr - selection\pos2\charNr)
		Selection_Clear(*te, *cursor)
		
		If ListSize(*te\textLine()) = 1
			*te\maxTextWidth = Textline_Width(*te, FirstElement(*te\textLine()))
		EndIf
		
		ProcedureReturn #True
	EndProcedure
	
	Procedure Selection_SetRange(*te.TE_STRUCT, *cursor.TE_CURSOR, lineNr, charNr, highLight = #True, checkOverlap = #True)
		; lineNr = index into List *te\textLine()
		
		ProcedureReturnIf((*te = #Null) Or (*cursor = #Null))
		
		Protected result = #False
		
		If lineNr > ListSize(*te\textLine())
			lineNr = ListSize(*te\textLine())
			charNr = Textline_LastCharNr(*te, lineNr) - 1
		Else
			lineNr = Clamp(lineNr, 1, ListSize(*te\textLine()))
			charNr = Max(charNr, 1)
		EndIf
		
		Selection_Start(*cursor, lineNr, charNr)
		
		If *cursor\position\lineNr <> lineNr
			SyntaxHighlight_Clear(*te)
		ElseIf highLight And (ListSize(*te\cursor()) = 1)
			RepeatedSelection_Update(*te, *cursor\position\lineNr, *cursor\position\charNr, lineNr, charNr)
		EndIf
		
		If checkOverlap
			*cursor = Cursor_DeleteOverlapping(*te, *cursor)
		EndIf
		
		If *cursor And Position_Equal(*cursor\position, *cursor\selection) = 0
			result = #True
		EndIf
		
		ProcedureReturn result
	EndProcedure
	
	Procedure Selection_Add(*range.TE_RANGE, lineNr, charNr)
		ProcedureReturnIf(*range = #Null)
		
		If (lineNr < *range\pos1\lineNr) Or ( (lineNr = *range\pos1\lineNr) And (charNr < *range\pos1\charNr))
			*range\pos1\lineNr = lineNr
			*range\pos1\charNr = charNr
		ElseIf (lineNr > *range\pos2\lineNr) Or ( (lineNr = *range\pos2\lineNr) And (charNr > *range\pos2\charNr))
			*range\pos2\lineNr = lineNr
			*range\pos2\charNr = charNr
		EndIf
	EndProcedure
	
	Procedure Selection_SetRectangle(*te.TE_STRUCT, *cursor.TE_CURSOR)
		ProcedureReturnIf((*te = #Null) Or (*cursor = #Null) Or (GetFlag(*te, #TE_EnableSelection) = 0))
		
		Cursor_Clear(*te, *cursor)
		
		Protected *firstLine.TE_TEXTLINE, *lastLine.TE_TEXTLINE
		
		If *cursor\firstPosition\lineNr < *cursor\position\lineNr
			*firstLine = *cursor\firstPosition\textline
			*lastLine = *cursor\position\textline
		Else
			*firstLine = *cursor\position\textline
			*lastLine = *cursor\firstPosition\textline
		EndIf
		
		If *firstLine And *lastLine
			ChangeCurrentElement(*te\textLine(), *firstLine)
			
			Repeat
				If *te\textLine() <> *cursor\position\textline
					Cursor_Add(*te, ListIndex(*te\textLine()) + 1, Textline_CharNrFromScreenPos(*te, *te\textLine(), *cursor\position\charX), #False)
				EndIf
			Until (*te\textLine() = *lastLine) Or (NextElement(*te\textLine()) = #Null)

			PushListPosition(*te\cursor())
			ForEach *te\cursor()
				Protected charNr = Textline_CharNrFromScreenPos(*te, *te\cursor()\position\textline, *cursor\firstPosition\charX)
				Selection_SetRange(*te, *te\cursor(), *te\cursor()\position\lineNr, charNr, #False, #False)
				CopyStructure(*cursor\firstPosition, *te\cursor()\firstPosition, TE_POSITION)
			Next
			PopListPosition(*te\cursor())
			
			Find_SetSelectionCheckbox(*te)
		EndIf
		
		ProcedureReturn ListSize(*te\cursor())
	EndProcedure
	
	Procedure Selection_SelectAll(*te.TE_STRUCT)
		ProcedureReturnIf((*te = #Null) Or (GetFlag(*te, #TE_EnableSelection) = 0))
		
		Cursor_Clear(*te, *te\maincursor)
		
		Cursor_Position(*te, *te\maincursor, 1, 1)
		
		ProcedureReturn Selection_SetRange(*te, *te\maincursor, ListSize(*te\textLine()), Textline_Length(LastElement(*te\textLine())) + 1)
	EndProcedure
	
	Procedure Selection_SelectTextBlock(*te.TE_STRUCT, lineNr)
		ProcedureReturnIf((*te = #Null) Or (GetFlag(*te, #TE_EnableSelection) = 0))
		
		Protected selection.TE_RANGE, count
		
		If Parser_TokenAtCharNr(*te, *te\currentCursor\position\textline, *te\currentCursor\position\charNr - 1)
			Repeat
				If FindMapElement(*te\syntax(), LCase(TokenText(*te\parser\token)))
					If *te\syntax()\flags & #TE_Syntax_Start
						count + 1
						If count = 1
							selection\pos1\lineNr = *te\parser\lineNr
							selection\pos1\charNr = *te\parser\token\charNr; + *te\parser\token\size
						EndIf
					EndIf
					If *te\syntax()\flags & #TE_Syntax_End
						count - 1
					EndIf
				EndIf
			Until selection\pos1\lineNr Or Parser_NextToken(*te, -1, #TE_Parser_SkipWhiteSpace | #TE_Parser_SkipBlankLines | #TE_Parser_Multiline) = #Null
		EndIf
		
		If Parser_TokenAtCharNr(*te, *te\currentCursor\position\textline, *te\currentCursor\position\charNr)
			Repeat
				If FindMapElement(*te\syntax(), LCase(TokenText(*te\parser\token)))
					If *te\syntax()\flags & #TE_Syntax_Start
						count + 1
					EndIf
					If *te\syntax()\flags & #TE_Syntax_End
						count - 1
						If count = 0
							selection\pos2\lineNr = *te\parser\lineNr
							selection\pos2\charNr = *te\parser\token\charNr + *te\parser\token\size
						EndIf
					EndIf
				EndIf
			Until selection\pos2\lineNr Or Parser_NextToken(*te, 1, #TE_Parser_SkipWhiteSpace | #TE_Parser_SkipBlankLines | #TE_Parser_Multiline) = 0
		EndIf
		
		If selection\pos1\lineNr And selection\pos2\lineNr
			Cursor_Position(*te, *te\currentCursor, selection\pos1\lineNr, selection\pos1\charNr)
			Selection_SetRange(*te, *te\currentCursor, selection\pos2\lineNr, selection\pos2\charNr)
			ProcedureReturn #True
		EndIf
		
		ProcedureReturn #False
		
		Protected *parentTextBlock, *textBlock.TE_TEXTBLOCK = Folding_GetTextBlock(*te, lineNr)
		If *textBlock And *te\currentCursor\position\lineNr = *textBlock\firstLineNr And *te\currentCursor\position\charNr = 1
			*parentTextBlock = Folding_GetTextBlock(*te, lineNr - 1)
			If *parentTextBlock
				*textBlock = *parentTextBlock
			EndIf
		EndIf
		
		If *textBlock
			Folding_UnfoldTextline(*te, lineNr)
			Cursor_Position(*te, *te\currentCursor, *textBlock\firstLineNr, 1)
			Selection_SetRange(*te, *te\currentCursor, *textBlock\lastLineNr, Textline_LastCharNr(*te, *textBlock\lastLineNr))
		EndIf
		
		ProcedureReturn *textBlock
	EndProcedure
	
	Procedure Selection_Clear(*te.TE_STRUCT, *cursor.TE_CURSOR)
		ProcedureReturnIf((*te = #Null) Or (*cursor = #Null))
		
		; 		If Cursor_HasSelection(*cursor)
		; 			*te\redrawMode | #TE_Redraw_All
		; 		EndIf
		
		RepeatedSelection_Clear(*te)
		Selection_Start(*cursor, 0, 0)
	EndProcedure
	
	Procedure Selection_ClearAll(*te.TE_STRUCT, deleteCursors = #False)
		ProcedureReturnIf(*te = #Null)
		
		If deleteCursors
			Cursor_Clear(*te, *te\maincursor)
		EndIf
		
		PushListPosition(*te\cursor())
		ForEach *te\cursor()
			Selection_Start(*te\cursor(), 0, 0)
		Next
		PopListPosition(*te\cursor())
		
		RepeatedSelection_Clear(*te)
		
		If IsGadget(*te\find\chk_insideSelection)
			DisableGadget(*te\find\chk_insideSelection, #True)
		EndIf
	EndProcedure
	
	Procedure.s Selection_Text(*te.TE_STRUCT, delimiter.s = "")
		ProcedureReturnIf(*te = #Null, "")
		
		Protected.s result, lastText, currentText
		Protected count
		
		SortStructuredList(*te\cursor(), #PB_Sort_Ascending, OffsetOf(TE_CURSOR\number), TypeOf(TE_CURSOR\number))
		
		PushListPosition(*te\cursor())
		ForEach *te\cursor()
			;lastText = LCase(currentText)
			currentText = Text_Get(*te, *te\cursor()\position\lineNr, *te\cursor()\position\charNr, *te\cursor()\selection\lineNr, *te\cursor()\selection\charNr)
			
			If lastText <> LCase(currentText)
				If count
					result + delimiter
				EndIf
				
				result + currentText
				count + 1
			EndIf
		Next
		PopListPosition(*te\cursor())
		
		ProcedureReturn result
	EndProcedure
	
	Procedure Selection_Unfold(*te.TE_STRUCT, startLine, endLine)
		ProcedureReturnIf((*te = #Null) Or (ListSize(*te\textLine()) = 0))
	EndProcedure
	
	Procedure Selection_Move(*te.TE_STRUCT, direction)
		ProcedureReturnIf((*te = #Null) Or (*te\currentCursor = #Null) Or (direction = 0))
		
		Protected *cursor.TE_CURSOR = *te\currentCursor
		Protected selection.TE_RANGE
		Protected text.s
		
		direction = Clamp(direction, -1, 1)
		
		Cursor_Clear(*te, *cursor)
		
		If Cursor_HasSelection(*cursor) = #False
			Cursor_Position(*te, *cursor, *cursor\position\lineNr, 1)
			Selection_SetRange(*te, *cursor, *cursor\position\lineNr, Textline_LastCharNr(*te, *cursor\position\lineNr))
		EndIf
		
		If Selection_Get(*cursor, selection)
			Undo_Start(*te, *te\undo)
			If (direction < 0) And (selection\pos1\lineNr > 1)
				
				Cursor_Position(*te, *cursor, selection\pos1\lineNr - 1, 1, #True, #True, *te\undo)
				Selection_SetRange(*te, *cursor, selection\pos1\lineNr, 1)
				text = Text_Get(*te, *cursor\position\lineNr, *cursor\position\charNr, *cursor\selection\lineNr, *cursor\selection\charNr)
				
				If Remark_IsSelected(*te, selection\pos1\lineNr, selection\pos2\lineNr + 1) = #False And Selection_Delete(*te, *cursor, *te\undo)
					If (selection\pos2\lineNr) > ListSize(*te\textLine())
						text = *te\newLineText + RTrim(text, *te\newLineText)
					EndIf
					Cursor_Position(*te, *cursor, selection\pos2\lineNr, 1)
					Textline_AddText(*te, *cursor, @text, Len(text), #TE_Styling_All, *te\undo)
					
					Cursor_Position(*te, *cursor, selection\pos1\lineNr - 1, 1)
					Selection_SetRange(*te, *cursor, selection\pos2\lineNr - 1, Textline_LastCharNr(*te, selection\pos2\lineNr - 1))
				EndIf
			ElseIf (direction > 0) And (selection\pos2\lineNr < ListSize(*te\textLine()))
				Cursor_Position(*te, *cursor, selection\pos2\lineNr + 1, 1, #True, #True, *te\undo)
				Selection_SetRange(*te, *cursor, selection\pos2\lineNr + 2, 1)
				text = Text_Get(*te, *cursor\position\lineNr, *cursor\position\charNr, *cursor\selection\lineNr, *cursor\selection\charNr)
				
				If selection\pos2\lineNr > ListSize(*te\textLine()) - 2
					Cursor_Position(*te, *cursor, ListSize(*te\textLine()) - 1, Textline_LastCharNr(*te, ListSize(*te\textLine()) - 1))
				EndIf
				
				If Remark_IsSelected(*te, selection\pos1\lineNr, selection\pos2\lineNr) = #False  And Selection_Delete(*te, *cursor, *te\undo)
					If selection\pos2\lineNr > ListSize(*te\textLine()) - 1
						text + *te\newLineText
					EndIf
					Cursor_Position(*te, *cursor, selection\pos1\lineNr, 1)
					Textline_AddText(*te, *cursor, @text, Len(text), #TE_Styling_All, *te\undo)
					
					Selection_SetRange(*te, *cursor, selection\pos2\lineNr + 1, Textline_LastCharNr(*te, selection\pos2\lineNr + 1))
				EndIf
			Else
				Cursor_Position(*te, *cursor, selection\pos1\lineNr, 1)
				Selection_SetRange(*te, *cursor, selection\pos2\lineNr, Textline_LastCharNr(*te, selection\pos2\lineNr))
			EndIf
			Undo_Update(*te)
			
			*te\redrawMode | #TE_Redraw_ChangedLines
			*te\needFoldUpdate = #True
		EndIf
	EndProcedure
	
	Procedure Selection_Clone(*te.TE_STRUCT, *cursor.TE_CURSOR)
		ProcedureReturnIf((*te = #Null) Or (*cursor = #Null))
		
		Protected text.s
		Protected lastLine
		
		Protected previousLineNr = *cursor\position\lineNr
		Protected previousCharNr = *cursor\position\charNr
		
		If *cursor\position\textline And *cursor\position\textline\foldState & #TE_Folding_Folded
			Folding_UnfoldTextline(*te, *cursor\position\lineNr)
		EndIf
		
		text.s = Text_Get(*te, *cursor\position\lineNr, *cursor\position\charNr, *cursor\selection\lineNr, *cursor\selection\charNr)
		
		If text = ""
			text = *te\newLineText + *cursor\position\textline\text
			Cursor_Position(*te, *cursor, *cursor\position\lineNr, Textline_Length(*cursor\position\textline) + 1)
		EndIf
		
		If text
			Textline_AddText(*te, *cursor, @text, Len(text), #TE_Styling_CaseCorrection | #TE_Styling_UpdateFolding | #TE_Styling_UpdateIndentation, *te\undo)
			lastLine = *cursor\position\lineNr
			
			Cursor_Position(*te, *cursor, previousLineNr, previousCharNr)
			
			ProcedureReturn lastLine
		EndIf
	EndProcedure
	
	Procedure Selection_Comment(*te.TE_STRUCT, *cursor.TE_CURSOR)
		ProcedureReturnIf((*te = #Null) Or (*cursor = #Null))
		
		Protected result = #False
		Protected i
		Protected selection.TE_RANGE
		Protected commentText.s = *te\commentChar + " "
		
		If Selection_Get(*cursor, selection) = #False
			selection\pos1\lineNr = *cursor\position\lineNr
			selection\pos2\lineNr = *cursor\position\lineNr
		EndIf
		
		If Textline_FromLine(*te, selection\pos1\lineNr)
			Repeat
				PushListPosition(*te\textLine())
				Cursor_Position(*te, *cursor, ListIndex(*te\textLine()) + 1, 1)
				If Textline_AddText(*te, *cursor, @commentText, Len(commentText), #TE_Styling_UpdateFolding, *te\undo)
					result = #True
				EndIf
				PopListPosition(*te\textLine())
			Until (ListIndex(*te\textLine()) >= selection\pos2\lineNr - 1) Or (NextElement(*te\textLine()) = #Null)
		EndIf
		
		Cursor_Position(*te, *cursor, selection\pos2\lineNr, Textline_LastCharNr(*te, selection\pos2\lineNr))
		Selection_SetRange(*te, *cursor, selection\pos1\lineNr, 1)
		
		ProcedureReturn result
	EndProcedure
	
	Procedure Selection_Uncomment(*te.TE_STRUCT, *cursor.TE_CURSOR)
		ProcedureReturnIf((*te = #Null) Or (*cursor = #Null))
		
		Protected result = #False
		Protected lineNr
		Protected selection.TE_RANGE, rng.TE_RANGE
		
		If Selection_Get(*cursor, selection) = #False
			selection\pos1\lineNr = *cursor\position\lineNr
			selection\pos2\lineNr = *cursor\position\lineNr
		EndIf
		
		If Textline_FromLine(*te, selection\pos1\lineNr)
			Repeat
				PushListPosition(*te\textLine())
				lineNr = ListIndex(*te\textLine()) + 1
				If Textline_FindText(@*te\textLine(), *te\commentChar + " ", @rng, #True) Or Textline_FindText(@*te\textLine(), *te\commentChar, @rng, #True)
					Cursor_Position(*te, *cursor, lineNr, rng\pos1\charNr)
					If Selection_SetRange(*te, *cursor, lineNr, rng\pos2\charNr, #False)
						Selection_Delete(*te, *cursor, *te\undo)
						result = #True
					EndIf
				EndIf
				PopListPosition(*te\textLine())
			Until (ListIndex(*te\textLine()) >= selection\pos2\lineNr - 1) Or (NextElement(*te\textLine()) = #Null)
		EndIf
		
		Cursor_Position(*te, *cursor, selection\pos2\lineNr, Textline_LastCharNr(*te, *cursor\position\lineNr))
		Selection_SetRange(*te, *cursor, selection\pos1\lineNr, 1)
		
		ProcedureReturn result
	EndProcedure
	
	Procedure Selection_MoveComment(*te.TE_STRUCT, dir)
		ProcedureReturnIf((*te = #Null))
		
		; align selected comments
		
		Protected result = #False
		Protected lineNr
		Protected selection.TE_RANGE
		Protected *token.TE_TOKEN
		Protected charNr, column, commentColumn
		Protected text.s
		Protected i
		
		PushListPosition(*te\textLine())
		PushListPosition(*te\cursor())
		
		; find min/max column of selected comments
		
		ForEach *te\cursor()
			If Selection_Get(*te\cursor(), selection)
				If Textline_FromLine(*te, selection\pos1\lineNr)
					Repeat
						lineNr = ListIndex(*te\textLine()) + 1
						For i = 1 To *te\textLine()\tokenCount
							*token = @*te\textLine()\token(i)
							If *token\type = #TE_Token_Comment
								column = Textline_ColumnFromCharNr(*te, *te\currentView, *te\textLine(), *token\charNr)
								
								If (dir > 0) And ( (column < commentColumn) Or (commentColumn = 0))
									commentColumn = column
								ElseIf (dir < 0) And (column > commentColumn)
									If (i > 1) And (*te\textLine()\token(i - 1)\type = #TE_Token_Whitespace)
										commentColumn = column
									EndIf
								EndIf
								Break
							EndIf
						Next
					Until (lineNr >= selection\pos2\lineNr) Or (NextElement(*te\textLine()) = #Null)
				EndIf
			EndIf
		Next
		
		; move the comments according to the min max position
		ForEach *te\cursor()
			If Selection_Get(*te\cursor(), selection)
				If Textline_FromLine(*te, selection\pos1\lineNr)
					Repeat
						lineNr = ListIndex(*te\textLine()) + 1
						For i = 1 To *te\textLine()\tokenCount
							*token = @*te\textLine()\token(i)
							If *token\type = #TE_Token_Comment
								column = Textline_ColumnFromCharNr(*te, *te\currentView, *te\textLine(), *token\charNr)
								If (dir < 0) And (column = commentColumn)
									If (i > 1) And (*te\textLine()\token(i - 1)\type = #TE_Token_Whitespace)
										Cursor_Position(*te, *te\cursor(), lineNr, *token\charNr - 1, #False, #False)
										Selection_SetRange(*te, *te\cursor(), lineNr, *token\charNr, #False, #False)
										Selection_Delete(*te, *te\cursor(), *te\undo)
										result = #True
									EndIf
								ElseIf (dir > 0) And (column = commentColumn)
									Cursor_Position(*te, *te\cursor(), lineNr, *token\charNr)
									If *te\useRealTab
										Textline_AddChar(*te, *te\cursor(), #TAB, #False, 0, *te\undo)
									Else
										text = Space(Textline_NextTabSize(*te, *te\textLine(), *token\charNr))
										Textline_AddText(*te, *te\cursor(), @text, Len(text), 0, *te\undo)
									EndIf
									result = #True
								EndIf
								Break
							EndIf
						Next
					Until (lineNr >= selection\pos2\lineNr) Or (NextElement(*te\textLine()) = #Null)
				EndIf
				
				Cursor_Position(*te, *te\cursor(), selection\pos2\lineNr, Textline_LastCharNr(*te, *te\cursor()\position\lineNr))
				Selection_SetRange(*te, *te\cursor(), selection\pos1\lineNr, 1)
			EndIf
		Next
		
		PopListPosition(*te\cursor())
		PopListPosition(*te\textLine())
		
		ProcedureReturn result
	EndProcedure
	
	Procedure Selection_Indent(*te.TE_STRUCT, *cursor.TE_CURSOR)
		ProcedureReturnIf((*te = #Null) Or (*cursor = #Null) Or (*cursor\position\lineNr = *cursor\selection\lineNr))
		
		Protected result = #False
		
		Protected charNr = *cursor\position\charNr
		Protected textLen = Textline_Length(*cursor\position\textline)
		Protected selTextLen
		
		Protected selection.TE_RANGE
		Protected previousLineNr = *cursor\position\lineNr
		Protected previousCharNr = *cursor\position\charNr
		Protected *token.TE_TOKEN
		Protected lastSel.TE_POSITION, lastPos.TE_POSITION
		CopyStructure(*cursor\selection, lastSel, TE_POSITION)
		CopyStructure(*cursor\position, lastPos, TE_POSITION)
		
		If Selection_Get(*cursor, selection) = #False
			ProcedureReturn #False
		EndIf
		
		PushListPosition(*te\textLine())
		selTextLen = Textline_Length(Textline_FromLine(*te, *cursor\selection\lineNr))
		If Textline_FromLine(*te, selection\pos1\lineNr)
			Repeat
				PushListPosition(*te\textLine())
				Cursor_Position(*te, *cursor, ListIndex(*te\textLine()) + 1, 1)
				result + Indentation_Add(*te, *cursor)
				PopListPosition(*te\textLine())
			Until (ListIndex(*te\textLine()) + 1 >= selection\pos2\lineNr) Or (NextElement(*te\textLine()) = #Null)
		EndIf
		PopListPosition(*te\textLine())
		
		Cursor_Position(*te, *cursor, lastPos\lineNr, charNr + (Textline_Length(lastPos\textline) - textLen))
		If (lastSel\lineNr = *cursor\position\lineNr) And (lastSel\charNr = charNr)
			Selection_Clear(*te, *cursor)
		Else
			Selection_SetRange(*te, *cursor, lastSel\lineNr, lastSel\charNr + (Textline_Length(Textline_FromLine(*te, lastSel\lineNr)) - selTextLen))
		EndIf
		
		*te\needScrollUpdate = #False
		ProcedureReturn result
	EndProcedure
	
	Procedure Selection_Unindent(*te.TE_STRUCT, *cursor.TE_CURSOR)
		ProcedureReturnIf((*te = #Null) Or (*cursor = #Null)); Or (*cursor\position\lineNr = *cursor\selection\lineNr))
		
		Protected result = 0
		
		Protected charNr = *cursor\position\charNr
		Protected textLen = Textline_Length(*cursor\position\textline)
		Protected selTextLen
		Protected selection.TE_RANGE
		Protected lastSel.TE_POSITION, lastPos.TE_POSITION
		CopyStructure(*cursor\selection, lastSel, TE_POSITION)
		CopyStructure(*cursor\position, lastPos, TE_POSITION)
		lastSel\textline = Textline_FromLine(*te, lastSel\lineNr)
		
		If Selection_Get(*cursor, selection) = #False
			selection\pos1\lineNr = *cursor\position\lineNr
			selection\pos2\lineNr = *cursor\position\lineNr
		EndIf
		
		PushListPosition(*te\textLine())
		selTextLen = Textline_Length(Textline_FromLine(*te, *cursor\selection\lineNr))
		If Textline_FromLine(*te, selection\pos1\lineNr)
			Repeat
				PushListPosition(*te\textLine())
				Cursor_Position(*te, *cursor, ListIndex(*te\textLine()) + 1, 1)
				result + Indentation_LTrim(*te, *cursor)
				PopListPosition(*te\textLine())
			Until (ListIndex(*te\textLine()) + 1 >= selection\pos2\lineNr) Or (NextElement(*te\textLine()) = #Null)
		EndIf
		
		Cursor_Position(*te, *cursor, lastPos\lineNr, charNr + (Textline_Length(lastPos\textline) - textLen))
		If (lastSel\lineNr = *cursor\position\lineNr) And (lastSel\charNr = charNr)
			Selection_Clear(*te, *cursor)
		Else
			Selection_SetRange(*te, *cursor, lastSel\lineNr, lastSel\charNr + (Textline_Length(lastSel\textline) - selTextLen))
		EndIf
		PopListPosition(*te\textLine())
		
		*te\needScrollUpdate = #False
		ProcedureReturn result
	EndProcedure
	
	Procedure Selection_Beautify(*te.TE_STRUCT, *cursor.TE_CURSOR)
		ProcedureReturnIf((*te = #Null) Or (*cursor = #Null))
		
		Protected result = 0
		Protected selection.TE_RANGE
		
		If Selection_Get(*cursor, selection) = #False
			selection\pos1\lineNr = *cursor\position\lineNr
			selection\pos2\lineNr = *cursor\position\lineNr
		EndIf
		
		PushListPosition(*te\textLine())
		If Textline_FromLine(*te, selection\pos1\lineNr)
			Repeat
				result + Textline_Beautify(*te, *te\textLine())
			Until (ListIndex(*te\textLine()) + 1 >= selection\pos2\lineNr) Or (NextElement(*te\textLine()) = #Null)
		EndIf
		
		If result
			Indentation_Range(*te, selection\pos1\lineNr, selection\pos2\lineNr, *cursor)
		EndIf
		PopListPosition(*te\textLine())
		
		ProcedureReturn result
	EndProcedure
	
	Procedure Selection_IsAnythingSelected(*te.TE_STRUCT)
		ProcedureReturnIf(*te = #Null)
		
		Protected result = #False
		Protected selection.TE_RANGE
		
		PushListPosition(*te\cursor())
		ForEach *te\cursor()
			Selection_Get(*te\cursor(), @selection)		
			If (selection\pos1\lineNr <= 0) Or (selection\pos2\lineNr <= 0)
			ElseIf (selection\pos1\lineNr <> selection\pos2\lineNr) Or
			       (selection\pos1\charNr <> selection\pos2\charNr)
				result = #True
				Break
			EndIf
		Next
		PopListPosition(*te\cursor())
		
		ProcedureReturn result
	EndProcedure
	
	Procedure Selection_Overlap(*sel1.TE_RANGE, *sel2.TE_RANGE)
		If *sel1\pos1\lineNr > *sel2\pos1\lineNr
			Swap *sel1, *sel2
		ElseIf (*sel1\pos1\lineNr = *sel2\pos2\lineNr) And (*sel1\pos1\charNr > *sel2\pos1\charNr)
			Swap *sel1, *sel2
		EndIf
		
		If *sel1\pos2\lineNr < *sel2\pos1\lineNr
			ProcedureReturn #False
		ElseIf (*sel1\pos2\lineNr = *sel2\pos1\lineNr) And (*sel1\pos2\charNr <= *sel2\pos1\charNr)
			ProcedureReturn #False
		EndIf
		
		ProcedureReturn #True
	EndProcedure
	
	Procedure Selection_FromTextLine(*te.TE_STRUCT, *textline.TE_TEXTLINE, *result.TE_RANGE)
		ProcedureReturnIf((*te = #Null) Or (*textline = #Null) Or (*result = #Null))
		
		Protected selection.TE_RANGE
		Protected lineNr = Textline_LineNr(*te, *textline)
		Protected found = #False
		
		PushListPosition(*te\cursor())
		ForEach *te\cursor()
			If Selection_Get(*te\cursor(), selection)
				If (selection\pos1\lineNr <= lineNr) And (selection\pos2\lineNr >= lineNr)
					If selection\pos1\lineNr = lineNr
						*result\pos1\lineNr = lineNr
						*result\pos1\charNr = selection\pos1\charNr
					ElseIf selection\pos1\lineNr < lineNr
						*result\pos1\charNr = 1
					EndIf
					If selection\pos2\lineNr = lineNr
						*result\pos2\lineNr = lineNr
						*result\pos2\charNr = selection\pos2\charNr
					ElseIf selection\pos2\lineNr > lineNr
						*result\pos2\charNr = Len(*textline\text)
					EndIf
					found = #True
				EndIf
			EndIf
		Next
		PopListPosition(*te\cursor())
		
		ProcedureReturn found
	EndProcedure
	
	Procedure Selection_ChangeCase(*te.TE_STRUCT, mode)
		ProcedureReturnIf(*te = #Null)
		
		Protected result
		Protected text.s, newText.s
		
		PushListPosition(*te\cursor())
		ForEach *te\cursor()
			text = Text_Get(*te, *te\cursor()\position\lineNr, *te\cursor()\position\charNr, *te\cursor()\selection\lineNr, *te\cursor()\selection\charNr)
			
			If mode = #TE_Text_LowerCase
				newText = LCase(text)
			Else
				newText = UCase(text)
			EndIf
			If text <> newText
				Selection_Delete(*te, *te\cursor(), *te\undo)
				Selection_Start(*te\cursor(), *te\cursor()\position\lineNr, *te\cursor()\position\charNr)
				result + Textline_AddText(*te, *te\cursor(), @newText, Len(newText), #TE_Styling_All | #TE_Styling_NoUndo, *te\undo)
			EndIf
		Next
		PopListPosition(*te\cursor())
		
		ProcedureReturn result
	EndProcedure
	
	Procedure Selection_CharCount(*te.TE_STRUCT, *cursor.TE_CURSOR)
		ProcedureReturnIf(*te = #Null Or *cursor = #Null)
		
		Protected lineNr, charCount
		Protected *textline.TE_TEXTLINE
		Protected selection.TE_RANGE
		If Selection_Get(*cursor, @selection)
			If selection\pos1\lineNr = selection\pos2\lineNr
				charCount = selection\pos2\charNr - selection\pos1\charNr
			Else
				charCount = Textline_LastCharNr(*te, selection\pos1\lineNr) - selection\pos1\charNr
				lineNr = selection\pos1\lineNr + 1
				*textline = Textline_FromLine(*te, lineNr) 
				While *textline And lineNr < selection\pos2\lineNr
					charCount + Textline_LastCharNr(*te, lineNr)
					*textline = NextElement(*te\textLine())
					lineNr + 1
				Wend
				charCount + selection\pos2\charNr
			EndIf
		EndIf
		
		ProcedureReturn charCount
	EndProcedure
	
	Procedure Selection_WholeWord(*te.TE_STRUCT, *cursor.TE_CURSOR, lineNr, charNr, *result.TE_RANGE = #Null)
		ProcedureReturnIf(*te = #Null)
		
		; if *result is #Null the token under the cursor will be selected
		; otherwise, the range of the token will be returned in *result
		
		Protected parser.TE_PARSER
		Protected selection.TE_RANGE
		Protected *textline.TE_TEXTLINE = Textline_FromLine(*te, lineNr)
		Protected *token.TE_TOKEN = Parser_TokenAtCharNr(*te, *textline, charNr)
		
		If *textline And *token
			selection\pos1\lineNr = lineNr
			selection\pos1\charNr = *token\charNr
			selection\pos2\lineNr = lineNr
			selection\pos2\charNr = *token\charNr + *token\size
			
			Protected style = *textline\style(*token\charNr)
			
			If style <> #TE_Style_Comment And style <> #TE_Style_String
				CopyStructure(*te\parser, parser, TE_PARSER)
				While Parser_NextToken(*te, -1, 0) And (*textline\style(*te\parser\token\charNr) = style)
					selection\pos1\charNr = *te\parser\token\charNr 
				Wend
				CopyStructure(parser, *te\parser, TE_PARSER)
				While Parser_NextToken(*te, 1, 0) And (*textline\style(*te\parser\token\charNr) = style)
					selection\pos2\charNr = *te\parser\token\charNr + *te\parser\token\size
				Wend
			EndIf
			
			If *result
				CopyStructure(@selection, *result, TE_RANGE)
			ElseIf *cursor
				Cursor_Position(*te, *cursor, selection\pos2\lineNr, selection\pos2\charNr)
				Selection_SetRange(*te, *cursor, selection\pos1\lineNr, selection\pos1\charNr, 0, 0)
			EndIf
		EndIf
		
		ProcedureReturn *token
	EndProcedure
	
	;-
	;- ----------- CURSOR -----------
	;-
	
	Procedure Cursor_Thread(*window.TE_WINDOW)
		ProcedureReturnIf (*window = #Null)
		
		Protected *te.TE_STRUCT
		
		Repeat
 			LockMutex(_PBEdit_Mutex)			
  			*te = *window\activeEditor
  			If *te
				PostEvent(#TE_Event_CursorBlink, 0, 0, 0, *te)
 			EndIf
 			UnlockMutex(_PBEdit_Mutex)

 			Delay(500)
		Until *te = #Null
	EndProcedure

	
	Procedure Cursor_Add(*te.TE_STRUCT, lineNr, charNr, checkOverlap = #True, startSelection = #True)
		ProcedureReturnIf(*te = #Null)
		
		Protected *cursor.TE_CURSOR
		Protected selection.TE_RANGE
		Protected position.TE_POSITION
		
		
		SetFlag(*te, #TE_EnableMultiCursorPaste, 0)
		ForEach *te\cursor()
			*te\cursor()\clipBoard = ""
		Next
		
		position\lineNr = lineNr
		position\charNr = charNr
		
		If (GetFlag(*te, #TE_EnableMultiCursor) = 0) And (ListSize(*te\cursor()) > 0)
			ProcedureReturn *te\currentCursor
		EndIf
		
		If ListSize(*te\cursor()) >= #TE_MaxCursors
			ProcedureReturn #Null
		EndIf
		
		If checkOverlap
			ForEach *te\cursor()
				If Selection_Get(*te\cursor(), selection) And Position_InsideRange(position, selection)
					ProcedureReturn Cursor_Delete(*te, *te\cursor())
				ElseIf Position_Equal(*te\cursor()\position, position)
					ProcedureReturn Cursor_Delete(*te, *te\cursor())
				EndIf
			Next
		EndIf
		
		*cursor = AddElement(*te\cursor())
		
		If *cursor
			If *te\maincursor = #Null
				*te\maincursor = *cursor
			EndIf
			
			*cursor\number = ListIndex(*te\cursor())
			*te\currentCursor = *cursor
			*te\currentCursor\isVisible = #True
			Selection_Start(*te\currentCursor, 0, 0)
			Cursor_Position(*te, *cursor, lineNr, charNr)
			
			Cursor_Sort(*te)
			
			If checkOverlap
				ChangeCurrentElement(*te\cursor(), *cursor)
				If PreviousElement(*te\cursor())
					If Selection_Get(*te\cursor(), selection)
						If Position_InsideRange(*cursor\position, selection)
							*cursor = Cursor_Delete(*te, *te\cursor())
						EndIf
					EndIf
				EndIf
				
				If *cursor
					Cursor_Sort(*te)
					
					ChangeCurrentElement(*te\cursor(), *cursor)
					If NextElement(*te\cursor())
						If Selection_Get(*te\cursor(), selection)
							If Position_InsideRange(*cursor\position, selection)
								*cursor = Cursor_Delete(*te, *te\cursor())
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		
		If *cursor
			CopyStructure(*cursor\position, *te\cursorState\previousPosition, TE_POSITION)
			CopyStructure(*cursor\position, *cursor\firstPosition, TE_POSITION)
			If startSelection
				Selection_Start(*cursor, *cursor\position\lineNr, *cursor\position\charNr)
				Selection_Get(*cursor, *te\cursorState\firstSelection)
			EndIf
		EndIf
		
		PostEvent(#TE_Event_Cursor, *te\window, 0, #TE_EventType_Add)
		
		ProcedureReturn *cursor
	EndProcedure
	
	Procedure Cursor_Delete(*te.TE_STRUCT, *cursor.TE_CURSOR)
		ProcedureReturnIf((*te = #Null) Or (*cursor = #Null))
		
		SetFlag(*te, #TE_EnableMultiCursorPaste, 0)
		ForEach *te\cursor()
			*te\cursor()\clipBoard = ""
		Next
		
		If ListSize(*te\cursor()) = 1
			*te\maincursor = LastElement(*te\cursor())
			*te\currentCursor = *te\maincursor
			
			ProcedureReturn *te\maincursor
		EndIf
		
		If *cursor = *te\maincursor
			*te\maincursor = #Null
		EndIf
		If *cursor = *te\currentCursor
			*te\currentCursor = #Null
		EndIf
		
		If Cursor_HasSelection(*cursor)
			*te\redrawMode | #TE_Redraw_All
		EndIf
		
		ChangeCurrentElement(*te\cursor(), *cursor)
		*cursor = DeleteElement(*te\cursor(), 1)
		
		If *te\maincursor = #Null
			*te\maincursor = *cursor
		EndIf
		If *te\currentCursor = #Null
			*te\currentCursor = *cursor
		EndIf
		
		*te\redrawMode | #TE_Redraw_ChangedLines
		*cursor\position\textline\needRedraw = #True
		
		
		PostEvent(#TE_Event_Cursor, *te\window, 0, #TE_EventType_Remove)
		
		ProcedureReturn *cursor
	EndProcedure
	
	Procedure Cursor_AddMultiFromText(*te.TE_STRUCT, text.s)
		Protected i, textLen
		Protected *c.Character
		Protected *currentCursor.TE_CURSOR = *te\currentCursor
		Protected *cursor.TE_CURSOR
		
		If text
			textLen = Len(text)
			
			ForEach *te\textLine()
				*c = @*te\textLine()\text
				i = 0
				
				While *c\c
					i + 1
					If CompareMemoryString(*c, @text, *te\cursorState\compareMode, textLen) = #PB_String_Equal
						*cursor = Cursor_Add(*te, ListIndex(*te\textLine()) + 1, i, #False)
						If *cursor
							Selection_Start(*cursor, *cursor\position\lineNr, *cursor\position\charNr)
							Selection_SetRange(*te, *cursor, *cursor\position\lineNr, *cursor\position\charNr + textLen, #False, #False)
						EndIf
					EndIf
					*c + #TE_CharSize
				Wend
			Next
		EndIf
		
		*te\currentCursor = *currentCursor
	EndProcedure
	
	
	Procedure Cursor_DeleteOverlapping(*te.TE_STRUCT, *cursor.TE_CURSOR, joinSelections = #False)
		ProcedureReturnIf((*te = #Null) Or (*cursor = #Null))
		
		Protected selection1.TE_RANGE
		Protected selection2.TE_RANGE
		Protected *currentCursor.TE_CURSOR
		Protected delete
		
		If ListSize(*te\cursor()) = 0
			ProcedureReturn #Null
		EndIf
		
		If ListIndex(*te\cursor()) >= 0
			*currentCursor = *te\cursor()
		EndIf
		
		Selection_Get(*cursor, selection1)
		
		Cursor_Sort(*te)
		
		ForEach *te\cursor()
			If *te\cursor() <> *cursor
				
				If *currentCursor = #Null
					*currentCursor = *te\cursor()
				EndIf
				
				delete = #False
				
				If (*te\cursor()\position\lineNr = *cursor\position\lineNr) And (*te\cursor()\position\charNr = *cursor\position\charNr)
					; SAME LOCATION
					delete = 1
				ElseIf Position_InsideRange(*te\cursor()\position, selection1)
					; INSIDE RANGE
					delete = 2
				ElseIf Selection_Get(*te\cursor(), selection2) And Cursor_HasSelection(*te\cursor()) And Selection_Overlap(selection1, selection2)
					;OVERLAP
					delete = 3
				EndIf
				
				If delete
					If *te\cursor() = *currentCursor
						*currentCursor = #Null
					EndIf
					
					If joinSelections And (delete > 1) And Selection_Get(*te\cursor(), selection2)
						Selection_Add(selection1, selection2\pos1\lineNr, selection2\pos1\charNr)
						;Selection_Add(selection1, selection2\pos2\lineNr, selection2\pos2\charNr)
						
						If *cursor\selection\lineNr > 0
							If (*cursor\position\lineNr < *cursor\selection\lineNr) Or (*cursor\position\lineNr = *cursor\selection\lineNr And (*cursor\position\charNr < *cursor\selection\charNr))
								Cursor_Position(*te, *cursor, selection1\pos1\lineNr, selection1\pos1\charNr)
								Selection_Start(*cursor, selection1\pos2\lineNr, selection1\pos2\charNr)
							Else
								Cursor_Position(*te, *cursor, selection1\pos2\lineNr, selection1\pos2\charNr)
								Selection_Start(*cursor, selection1\pos1\lineNr, selection1\pos1\charNr)
							EndIf
						EndIf
					EndIf
					
					Cursor_Delete(*te, *te\cursor())
				EndIf
				
			EndIf
		Next
		
		If *currentCursor
			ChangeCurrentElement(*te\cursor(), *currentCursor)
		EndIf
		
		ProcedureReturn *currentCursor
	EndProcedure
	
	Procedure Cursor_Clear(*te.TE_STRUCT, *maincursor.TE_CURSOR)
		ProcedureReturnIf((*te = #Null) Or (*maincursor = #Null))
		
		SetFlag(*te, #TE_EnableMultiCursorPaste, 0)
		ForEach *te\cursor()
			*te\cursor()\clipBoard = ""
			If *te\cursor() <> *maincursor
				DeleteElement(*te\cursor())
			EndIf
		Next
		
		*te\maincursor = *maincursor
		*te\currentCursor = *maincursor

		*te\redrawMode | #TE_Redraw_All
		
		PostEvent(#TE_Event_Cursor, *te\window, 0, #TE_EventType_Remove)
		
		ProcedureReturn #True
	EndProcedure
	
	Procedure Cursor_Set(*cursor.TE_CURSOR, *textline.TE_TEXTLINE, lineNr, visibleLineNr, charNr)
		ProcedureReturnIf(*cursor = #Null)
		
		*cursor\position\textline = *textline
		*cursor\position\lineNr = lineNr
		*cursor\position\visibleLineNr = visibleLineNr
		*cursor\position\charNr = charNr
	EndProcedure
	
	Procedure Cursor_LineHistoryAdd(*te.TE_STRUCT)
		ProcedureReturnIf((*te = #Null) Or (*te\currentCursor = #Null))
		
		Protected *cursor.TE_CURSOR = *te\currentCursor
		
		If Abs(*cursor\position\lineNr - *cursor\previousPosition\lineNr) > 20
			While ListSize(*te\lineHistory()) >= 20
				FirstElement(*te\lineHistory())
				DeleteElement(*te\lineHistory())
			Wend
			If LastElement(*te\lineHistory()) And (*te\lineHistory() = *cursor\previousPosition\lineNr)
				ProcedureReturn #False
			EndIf
			If AddElement(*te\lineHistory())
				*te\lineHistory() = *cursor\previousPosition\lineNr
				ProcedureReturn #True
			EndIf
		EndIf
	EndProcedure
	
	Procedure Cursor_LineHistoryGoto(*te.TE_STRUCT)
		ProcedureReturnIf((*te = #Null) Or (*te\maincursor = #Null))
		
		If LastElement(*te\lineHistory())
			Cursor_Position(*te, *te\maincursor, *te\lineHistory(), 1)
			If ListSize(*te\lineHistory()) > 1
				DeleteElement(*te\lineHistory())
			EndIf
			
			Selection_ClearAll(*te)
		EndIf
	EndProcedure
	
	Procedure Cursor_Sort(*te.TE_STRUCT, sortOrder = #PB_Sort_Ascending)
		ProcedureReturnIf(*te = #Null)
		
		; 	sort the cursors
		;	1. by lineNr from low to high
		;	2. by charNr from low to high
		
		Protected *start.TE_CURSOR, startIndex, endIndex
		
		SortStructuredList(*te\cursor(), #PB_Sort_Ascending, OffsetOf(TE_CURSOR\position) + OffsetOf(TE_POSITION\lineNr), TypeOf(TE_POSITION\lineNr))
		
		ForEach *te\cursor()
			*start = *te\cursor()
			startIndex = ListIndex(*te\cursor())
			While NextElement(*te\cursor())
				If *te\cursor()\position\textline = *start\position\textline
					endIndex = ListIndex(*te\cursor())
				Else
					PreviousElement(*te\cursor())
					Break
				EndIf
			Wend
			If endIndex > startIndex
				SortStructuredList(*te\cursor(), sortOrder, OffsetOf(TE_CURSOR\position) + OffsetOf(TE_POSITION\charNr), #PB_Integer, startIndex, endIndex)
				SelectElement(*te\cursor(), endIndex)
			EndIf
		Next
	EndProcedure
	
	Procedure Cursor_MoveMulti(*te.TE_STRUCT, *cursor.TE_CURSOR, previousLineNr, dirY, dirX)
		ProcedureReturnIf(ListSize(*te\cursor()) < 2)
		
		PushListPosition(*te\cursor())
		ChangeCurrentElement(*te\cursor(), *cursor)
		
		CopyStructure(*cursor\selection, *cursor\previousSelection, TE_POSITION)
		CopyStructure(*cursor\position, *cursor\previousPosition, TE_POSITION)
		
		While NextElement(*te\cursor())
			If dirX And (*te\cursor()\position\lineNr = previousLineNr)
				*te\cursor()\position\charNr + dirX
				
				If Cursor_HasSelection(*te\cursor())
					*te\cursor()\selection\charNr + dirX
				EndIf
			EndIf
			If dirY
				*te\cursor()\position\lineNr + dirY
				*te\cursor()\position\visibleLineNr + dirY
				*te\cursor()\position\textline = Textline_FromLine(*te, *te\cursor()\position\lineNr)
				
				If Cursor_HasSelection(*te\cursor())
					*te\cursor()\selection\lineNr + dirY
				EndIf
			EndIf
		Wend
		
		PopListPosition(*te\cursor())
	EndProcedure
	
	Procedure Cursor_Update(*te.TE_STRUCT, *cursor.TE_CURSOR, updateLastX, *undo.TE_UNDO = #Null)
		; needs to be called every time the cursorposition has changed.
		; - style the previous textline
		; - prepare redrawing of all cursors
		
		ProcedureReturnIf((*te = #Null) Or (*cursor = #Null))
		
		Protected result = #False
		
		; 				Cursor_DeleteOverlapping(*te, *cursor)
		
		If updateLastX
			*cursor\position\charX = Textline_CharNrToScreenPos(*te, *cursor\position\textline, *cursor\position\charNr)
			*cursor\position\currentX = *cursor\position\charX
		EndIf
		
		If *cursor\previousPosition\textline And (*cursor\previousPosition\textline <> *cursor\position\textline) And *cursor\previousPosition\textline\needStyling
			;style the previous textline
			If Parser_InsideStructure(*te, *cursor\previousPosition\textline, *cursor\previousPosition\charNr)
				Style_Textline(*te, *cursor\previousPosition\textline, 0, *undo);#TE_Styling_UpdateIndentation); | #TE_Styling_UpdateFolding)
			Else
				Style_Textline(*te, *cursor\previousPosition\textline, #TE_Styling_CaseCorrection | #TE_Styling_UpdateIndentation | #TE_Styling_UpdateFolding, *undo)
			EndIf
			*te\needDictionaryUpdate = #True
			*cursor\previousPosition\textline\needStyling = #False
		EndIf
		
		If (*cursor\previousPosition\textline <> *cursor\position\textline) Or (*cursor\previousPosition\charNr <> *cursor\position\charNr)
			If *cursor\position\textline
				*cursor\position\textline\needRedraw = #True
			EndIf
			If *cursor\previousPosition\textline
				*cursor\previousPosition\textline\needRedraw = #True
			EndIf
			
			*te\cursorState\blinkState = 1
			*te\cursorState\blinkSuspend = 1
			
			result = #True
		EndIf
		
		;*cursor\previousPosition\textline = *cursor\position\textline
		
		If Cursor_HasSelection(*cursor) = #False
			RepeatedSelection_Clear(*te)
		EndIf
		
		If *te\needDictionaryUpdate
 			Autocomplete_UpdateDictonary(*te, 0, 0)
		EndIf
		
		*te\redrawMode | #TE_Redraw_ChangedLines
		
		ProcedureReturn result
	EndProcedure
	
	Procedure Cursor_Move(*te.TE_STRUCT, *cursor.TE_CURSOR, dirY, dirX, *undo.TE_UNDO = #Null)
		; returnvalues:
		; #false	-	no current lineNr or cursorposition unchanged
		; #true		-	lineNr or charNr has changed
		
		ProcedureReturnIf((*te = #Null) Or ListSize(*te\textLine()) = 0)
		ProcedureReturnIf((dirX = 0) And (dirY = 0))
		
		Protected visibleLineNr
		
		; if cursor is inside folded block, jump outside
		Protected *textblock.TE_TEXTBLOCK = Folding_GetTextBlock(*te, *cursor\position\lineNr)
		If *textblock And (*textblock\firstLine\foldState & #TE_Folding_Folded)
			If *textblock\lastLineNr >= ListSize(*te\textLine()) - 1
				If (dirY > 0) Or (dirX > 0 And *cursor\position\charNr >= Textline_LastCharNr(*te, *cursor\position\lineNr) - 1)
					ProcedureReturn Cursor_Position(*te, *cursor, ListSize(*te\textLine()) + 1, 1, #False)
				EndIf
			EndIf
			
			If *cursor\position\lineNr > *textblock\firstLineNr
				If dirX < 0
					ProcedureReturn Cursor_Position(*te, *cursor, *textblock\firstLineNr, Len(*textblock\firstLine\text) + 1, #False)
				ElseIf dirX > 0
					ProcedureReturn Cursor_Position(*te, *cursor, *textblock\lastLineNr + 1, 1, #False)
				EndIf
				
				If dirY < 0
					ProcedureReturn Cursor_Position(*te, *cursor, *textblock\firstLineNr, *cursor\position\charNr, #False, #False)
				Else
					ProcedureReturn Cursor_Position(*te, *cursor, *textblock\lastLineNr + 1, *cursor\position\charNr, #False, #False)
				EndIf
			EndIf
		EndIf
		
		CopyStructure(*cursor\position, *cursor\previousPosition, TE_POSITION)
		
		If dirX
			If (*cursor\position\charNr + dirX) < 1
				If Cursor_Move(*te.TE_STRUCT, *cursor, -1, 0)
					*cursor\position\charNr = Max(1, Textline_Length(*cursor\position\textline) + 1)
				EndIf
			ElseIf ( (*cursor\position\charNr + dirX) > Textline_Length(*cursor\position\textline) + 1) And (*cursor\position\visibleLineNr < *te\visibleLineCount)
				If Cursor_Move(*te.TE_STRUCT, *cursor, 1, 0)
					*cursor\position\charNr = 1
				EndIf
			Else
				*cursor\position\charNr = Clamp(*cursor\position\charNr + dirX, 1, Textline_Length(*cursor\position\textline) + 1)
			EndIf

			ProcedureReturn Cursor_Update(*te, *cursor, #True)
		EndIf
		
		If dirY
			visibleLineNr = Clamp(*cursor\position\visibleLineNr + dirY, 1, *te\visibleLineCount)
			
			If Textline_FromVisibleLineNr(*te, visibleLineNr)
				*cursor\position\textline = *te\textLine()
				*cursor\position\lineNr = ListIndex(*te\textLine()) + 1
				*cursor\position\visibleLineNr = visibleLineNr
				
				If (*cursor\previousPosition\lineNr + dirY) < 1
					*cursor\position\charNr = 1
				ElseIf (*cursor\previousPosition\visibleLineNr + dirY) > *te\visibleLineCount
					*cursor\position\charNr = Textline_Length(*cursor\position\textline) + 1
				Else
					*cursor\position\charNr = Textline_CharNrFromScreenPos(*te, *cursor\position\textline, *cursor\position\currentX)
				EndIf
			EndIf
			
			ProcedureReturn Cursor_Update(*te, *cursor, #False, *undo)
		EndIf
	EndProcedure
	
	Procedure Cursor_Position(*te.TE_STRUCT, *cursor.TE_CURSOR, lineNr, charNr, ensureVisible = #True, updateLastX = #True, *undo.TE_UNDO = #Null)
		ProcedureReturnIf((*te = #Null) Or (*cursor = #Null) Or (ListSize(*te\textLine()) = 0))
		
		If ensureVisible
			Protected *textblock.TE_TEXTBLOCK = Folding_GetTextBlock(*te, lineNr)
			If *textblock And (*textblock\firstLine\foldState & #TE_Folding_Folded)
				lineNr = *textblock\firstLineNr
			EndIf
		EndIf
		
		If Textline_FromLine(*te, lineNr)
			*cursor\position\textline = *te\textLine()
			*cursor\position\lineNr = ListIndex(*te\textLine()) + 1
			*cursor\position\visibleLineNr = LineNr_to_VisibleLineNr(*te, *cursor\position\lineNr)
			
			If lineNr > ListSize(*te\textLine())
				*cursor\position\charNr = Textline_Length(*te\textLine()) + 1
			ElseIf lineNr < 1
				*cursor\position\charNr = 1
			Else
				*cursor\position\charNr = Clamp(charNr, 1, Textline_Length(*te\textLine()) + 1)
			EndIf
		EndIf
		
 		ProcedureReturn Cursor_Update(*te, *cursor, updateLastX, *undo)
	EndProcedure
	
	Procedure Cursor_GetScreenPos(*te.TE_STRUCT, *view.TE_VIEW, x, y, *result.TE_POSITION)
		ProcedureReturnIf((*te = #Null) Or (*view = #Null) Or (*result = #Null))
		
		x = DesktopUnscaledX(x)
		y = DesktopUnscaledY(y)
		
		*result\visibleLineNr = Clamp(*view\scroll\visibleLineNr + Round( (y - *te\topBorderSize) / *te\lineHeight, #PB_Round_Down), 1, *te\visibleLineCount)
		
		If GetFlag(*te, #TE_EnableWordWrap)
			Protected visibleLineNr
			For visibleLineNr = *result\visibleLineNr - 1 To *view\firstVisibleLineNr Step -1
				If Textline_FromVisibleLineNr(*te, visibleLineNr)
					*result\visibleLineNr - Int(*te\textLine()\TextWidth / (*view\width - *te\leftBorderOffset))
				EndIf
			Next
		EndIf
		
		If Textline_FromVisibleLineNr(*te, *result\visibleLineNr)
			*result\textline = *te\textLine()
			*result\lineNr = ListIndex(*te\textLine()) + 1
			*result\charNr = Textline_CharNrFromScreenPos(*te, *te\textLine(), x - *te\leftBorderOffset + *view\scroll\charX)
			ProcedureReturn #True
		EndIf
		
		ProcedureReturn #False
	EndProcedure
	
	Procedure Cursor_FromScreenPos(*te.TE_STRUCT, *view.TE_VIEW, *cursor.TE_CURSOR, x, y, addCursor = #False)
		ProcedureReturnIf((*te = #Null) Or (*view = #Null) Or (*cursor = #Null))
		
		Protected position.TE_POSITION
		
		If Cursor_GetScreenPos(*te, *view, x, y, position)
			If addCursor
				*cursor = Cursor_Add(*te, position\lineNr, position\charNr)
				
				If *cursor = #Null
					ProcedureReturn #Null
				EndIf
			Else
				Cursor_Position(*te, *cursor, position\lineNr, position\charNr)
			EndIf
		EndIf
		
		ProcedureReturn *cursor
	EndProcedure
	
	Procedure Cursor_HasSelection(*cursor.TE_CURSOR)
		ProcedureReturnIf((*cursor = #Null) Or (*cursor\selection\lineNr <= 0) Or (*cursor\selection\charNr <= 0))
		ProcedureReturnIf((*cursor\position\lineNr <> *cursor\selection\lineNr) Or (*cursor\position\charNr <> *cursor\selection\charNr), #True)
		
		ProcedureReturn #False
	EndProcedure
	
	Procedure Cursor_SelectionStart(*te.TE_STRUCT, *cursor.TE_CURSOR)
		ProcedureReturnIf((*te = #Null) Or (*cursor = #Null))
		
		Protected selection.TE_RANGE
		
		PushListPosition(*te\cursor())
		If Selection_Get(*cursor, selection)
			Cursor_Position(*te, *cursor, selection\pos1\lineNr, selection\pos1\charNr)
			Selection_SetRange(*te, *cursor, selection\pos2\lineNr, selection\pos2\charNr)
		EndIf
		PopListPosition(*te\cursor())
	EndProcedure
	
	Procedure Cursor_SelectionEnd(*te.TE_STRUCT, *cursor.TE_CURSOR)
		ProcedureReturnIf((*te = #Null) Or (*cursor = #Null))
		
		Protected selection.TE_RANGE
		
		PushListPosition(*te\cursor())
		If Selection_Get(*cursor, selection)
			Cursor_Position(*te, *cursor, selection\pos2\lineNr, selection\pos2\charNr)
			Selection_SetRange(*te, *cursor, selection\pos1\lineNr, selection\pos1\charNr)
			; 			*te\redrawMode | #TE_Redraw_All
		EndIf
		PopListPosition(*te\cursor())
	EndProcedure
	
	Procedure Cursor_NextWord(*te.TE_STRUCT, *cursor.TE_CURSOR, direction)
		ProcedureReturnIf((*te = #Null) Or (*cursor = #Null) Or (*cursor\position\textline = #Null))
		
		Protected result = 0
		
		If Parser_TokenAtCharNr(*te, *cursor\position\textline, *cursor\position\charNr)
			If Parser_NextToken(*te, direction, #TE_Parser_SkipWhiteSpace | #TE_Parser_SkipBlankLines | #TE_Parser_Multiline)
				result = Cursor_Position(*te, *cursor, Textline_LineNr(*te, *te\parser\textline), *te\parser\token\charNr)
			ElseIf direction > 0 And Textline_FromLine(*te, ListSize(*te\textLine()))
				result = Cursor_Position(*te, *cursor, ListIndex(*te\textLine()) + 2, 1)
			ElseIf direction < 0
				result = Cursor_Position(*te, *cursor, 1, 1)
			EndIf
		EndIf
		
		ProcedureReturn result
	EndProcedure
	
	; 	Procedure Cursor_InsideComment(*te.TE_STRUCT, *cursor.TE_CURSOR)
	; 		ProcedureReturnIf((*te = #Null) Or (*cursor = #Null))
	; 		
	; 		If Style_FromCharNr(*cursor\position\textline, *cursor\position\charNr, #True) = #TE_Style_Comment
	; 			ProcedureReturn #True
	; 		EndIf
	; ; 		Protected charNr = Clamp(*cursor\position\charNr, 1, ArraySize(*cursor\position\textline\style()))		
	; ; 		
	; ; 		If *cursor\position\textline\style(charNr) = #TE_Style_Comment
	; ; 			ProcedureReturn #True
	; ; 		EndIf
	; 		
	; 		ProcedureReturn #False
	; 	EndProcedure
	
	Procedure Cursor_GotoLineNr(*te.TE_STRUCT, *cursor.TE_CURSOR)
		ProcedureReturnIf((*te = #Null) Or (*cursor = #Null))
		
		Protected gotoLineNr.s = InputRequester(*te\language\gotoTitle, *te\language\gotoMessage, "")
		
		If gotoLineNr
			Folding_UnfoldTextline(*te, Val(gotoLineNr), #True)
			Selection_ClearAll(*te)
			Cursor_Position(*te, *cursor, Val(gotoLineNr), 1)
			Scroll_Line(*te, *te\currentView, *cursor, *cursor\position\visibleLineNr - 4)
			*te\needScrollUpdate = #False
			*te\needFoldUpdate = #False
		EndIf
	EndProcedure
	
	Procedure Cursor_SignalChanges(*te.TE_STRUCT, *cursor.TE_CURSOR)
		ProcedureReturnIf((*te = #Null) Or (*cursor = #Null))
		
		Protected posChanged = Position_Changed(*cursor\position, *cursor\previousPosition)
		Protected selChanged = Position_Changed(*cursor\selection, *cursor\previousSelection)
		
		If selChanged Or posChanged
			If posChanged
				PostEvent(#TE_Event_Cursor, *te\window, *te\currentView\canvas, #TE_EventType_Change)
			EndIf
			If (posChanged Or selChanged) And Cursor_HasSelection(*cursor)
				PostEvent(#TE_Event_Selection, *te\window, *te\currentView\canvas, #TE_EventType_Change)
				; 			ElseIf (posChanged Or selChanged) And (Cursor_HasSelection(*cursor) = 0 Or Position_Equal(*cursor\position, *cursor\selection))
			ElseIf (*cursor\previousSelection\lineNr > 0 And *cursor\previousSelection\charNr > 0) And (Cursor_HasSelection(*cursor) = 0 Or Position_Equal(*cursor\position, *cursor\selection))
				PostEvent(#TE_Event_Selection, *te\window, *te\currentView\canvas, #TE_EventType_Remove)
			EndIf
		EndIf
	EndProcedure
	
	;-
	;- ----------- DRAG & DROP -----------
	;-
	
	Procedure DragDrop_Start(*te.TE_STRUCT)
		ProcedureReturnIf(*te = #Null Or GetFlag(*te, #TE_EnableReadOnly))
		
		Protected dragTextPreviewSize = 32
		
		*te\cursorState\clickCount = 0
		*te\cursorState\dragDropMode = #TE_CursorState_DragMove
		*te\cursorState\dragText = Selection_Text(*te)
		*te\cursorState\dragStart = 0
		*te\cursorState\dragTextPreview = ""
		
		Protected i
		Protected lineCount = Min(5, CountString(*te\cursorState\dragText, *te\newLineText) + 1)
		
		For i = 1 To lineCount
			If i = 5
				*te\cursorState\dragTextPreview + "..."
			Else
				Protected textLine.s = StringField(*te\cursorState\dragText, i, *te\newLineText)
				textLine = ReplaceString(textLine, #TAB$, " ")
				If Len(textLine) < dragTextPreviewSize
					*te\cursorState\dragTextPreview + Left(textLine, dragTextPreviewSize) + #CRLF$
				Else
					*te\cursorState\dragTextPreview + Left(textLine, dragTextPreviewSize) + "..." + #CRLF$
				EndIf
			EndIf
		Next
		
		If *te\cursorState\dragText = ""
			*te\cursorState\dragDropMode = 0
		EndIf
		
		ProcedureReturn *te\cursorState\dragDropMode
	EndProcedure
	
	Procedure DragDrop_Stop(*te.TE_STRUCT)
		ProcedureReturnIf(*te = #Null)
		
		*te\cursorState\dragText = ""
		*te\cursorState\dragTextPreview = ""
		*te\cursorState\dragDropMode = 0
		*te\cursorState\dragStart = 0
		
		PostEvent(#TE_Event_Redraw, 0, 0, #TE_EventType_RedrawAll, *te\view)
	EndProcedure
	
	Procedure DragDrop_Cancel(*te.TE_STRUCT)
		ProcedureReturnIf((*te = #Null) Or (*te\cursorState\dragDropMode = 0) Or (*te\currentCursor = #Null))
		
		DragDrop_Stop(*te)
		
		*te\cursorState\dragDropMode = #TE_CursorState_Idle
	EndProcedure
	
	Procedure DragDrop_Drop(*te.TE_STRUCT)
		ProcedureReturnIf((*te = #Null) Or (*te\currentCursor = 0) Or (*te\cursorState\dragDropMode = 0))
		
		Protected *newCursor.TE_CURSOR
		Protected *cursor.TE_CURSOR = *te\currentCursor
		Protected checkBorder = Bool(*te\cursorState\dragDropMode & #TE_CursorState_DragCopy)
		Protected abort = #False
		Protected enableMultiCursor = GetFlag(*te, #TE_EnableMultiCursor)
		
		If Position_InsideSelection(*te, *te\currentView, *te\cursorState\mouseX, *te\cursorState\mouseY, checkBorder)
			abort = #True
		ElseIf *te\cursorState\dragText = ""
			abort = #True
		Else
			Undo_Start(*te, *te\undo)
			
			SetFlag(*te, #TE_EnableMultiCursor, 1)
			*newCursor = Cursor_Add(*te, *te\cursorState\dragPosition\lineNr, *te\cursorState\dragPosition\charNr)
			
			SetFlag(*te, #TE_EnableMultiCursor, enableMultiCursor)
			
			If *newCursor
				*newCursor\number = -1
			Else
				Debug "Error in DragDrop_Drop: *newCursor = #Null"
				*newCursor = *cursor
			EndIf
			
			If *te\cursorState\dragDropMode = #TE_CursorState_DragMove
				If LastElement(*te\cursor())
					Repeat
						If *te\cursor() <> *newCursor
							Selection_Delete(*te, *te\cursor(), *te\undo)
						EndIf
					Until PreviousElement(*te\cursor()) = #Null
				EndIf
			EndIf
			
			Selection_Start(*newCursor, *newCursor\position\lineNr, *newCursor\position\charNr)
			Textline_AddText(*te, *newCursor, @*te\cursorState\dragText, Len(*te\cursorState\dragText), #TE_Styling_All, *te\undo)
			
			Cursor_Clear(*te, *newCursor)
			
			Undo_Update(*te)
		EndIf
		
		RepeatedSelection_Clear(*te)
		DragDrop_Stop(*te)
		
		Folding_Update(*te, -1, -1)
		Scroll_UpdateAllViews(*te, *te\view, *te\currentView, *te\currentCursor)
		
		*te\redrawMode = #TE_Redraw_All
	EndProcedure
	
	;-
	;- ----------- CLIPBOARD -----------
	;-
	
	Procedure.s ClipBoard_GetSelectedText(*te.TE_STRUCT)
		ProcedureReturnIf(*te = #Null, "")
		
		Protected text.s, cursorText.s
		Protected cursorCount = ListSize(*te\cursor()) - 1
		
		If cursorCount > 0
			SetFlag(*te, #TE_EnableMultiCursorPaste, 1)
		Else
			SetFlag(*te, #TE_EnableMultiCursorPaste, 0)
		EndIf

		PushListPosition(*te\cursor())
		ForEach *te\cursor()
			cursorText = ""
			With *te\cursor()
				If cursorCount > 0
					If Cursor_HasSelection(*te\cursor())
						\clipBoard = Text_Get(*te, \position\lineNr, \position\charNr, \selection\lineNr, \selection\charNr)
 					Else
 						\clipBoard = ""
					EndIf
					cursorText =  \clipBoard
				Else
					If Cursor_HasSelection(*te\cursor())
						cursorText = Text_Get(*te, \position\lineNr, \position\charNr, \selection\lineNr, \selection\charNr)
					EndIf
				EndIf
			EndWith
			
			If cursorText
				text + cursorText
				If ListIndex(*te\cursor()) < cursorCount
					text + *te\newLineText
				EndIf
			EndIf
			
		Next
		PopListPosition(*te\cursor())

		ProcedureReturn text
	EndProcedure
	
	Procedure ClipBoard_Cut(*te.TE_STRUCT)
		ProcedureReturnIf(*te = #Null)
		
		Protected text.s = ClipBoard_GetSelectedText(*te)
		
		If text <> ""
			SetClipboardText(text)
			
			PushListPosition(*te\cursor())
			ForEach *te\cursor()
				Folding_UnfoldTextline(*te, *te\cursor()\position\lineNr, #False)
				Selection_Delete(*te, *te\cursor(), *te\undo)
			Next
			PopListPosition(*te\cursor())
			
			If *te\needFoldUpdate
				Folding_Update(*te, -1, -1)
			EndIf
		EndIf
	EndProcedure
	
	Procedure ClipBoard_Copy(*te.TE_STRUCT)
		ProcedureReturnIf(*te = #Null)
		
		Protected text.s = ClipBoard_GetSelectedText(*te)
		
		If text <> ""
			SetClipboardText(text)
		EndIf
	EndProcedure
	
	Procedure ClipBoard_Paste(*te.TE_STRUCT)
		ProcedureReturnIf(*te = #Null)
		
		Protected warning.s
		Protected text.s = GetClipboardText()
		Protected selection.TE_RANGE
		Protected cursorCount = ListSize(*te\cursor())
		
		If text = ""
			ProcedureReturn
		EndIf
		
		Selection_GetAll(*te, selection)
		If Remark_IsSelected(*te, selection\pos1\lineNr, selection\pos2\lineNr)
			ProcedureReturn #False
		EndIf
		
		
		If ListSize(*te\cursor()) > 1
			If (ListSize(*te\cursor()) * Len(text)) > 1000000
				warning = *te\language\warningLongText
				warning = ReplaceString(warning, "%N1", Str(Len(text)))
				warning = ReplaceString(warning, "%N2", Str(ListSize(*te\cursor())))
				
				If MessageRequester(*te\language\warningTitle, warning, #PB_MessageRequester_YesNo | #PB_MessageRequester_Warning) <> #PB_MessageRequester_Yes
					ProcedureReturn #False
				EndIf
			EndIf
		EndIf
		
		PushListPosition(*te\cursor())
		ForEach *te\cursor()
			Folding_UnfoldTextline(*te, *te\cursor()\position\lineNr, #False)
		Next
		PopListPosition(*te\cursor())
		
		If *te\needFoldUpdate
			Folding_Update(*te, -1, -1)
		EndIf
		
		ForEach *te\cursor()
			Selection_Delete(*te, *te\cursor(), *te\undo)
			
			With *te\cursor()
				If GetFlag(*te, #TE_EnableSelectPastedText)
					Selection_Start(*te\cursor(), \position\lineNr, \position\charNr)
				EndIf
				
				If GetFlag(*te, #TE_EnableMultiCursorPaste)
					If *te\cursor()\clipBoard
						Textline_AddText(*te, *te\cursor(), @*te\cursor()\clipBoard, Len(*te\cursor()\clipBoard), #TE_Styling_CaseCorrection | #TE_Styling_UpdateFolding | #TE_Styling_UpdateIndentation | #TE_Styling_UnfoldIfNeeded, *te\undo)
					EndIf
				Else
					Textline_AddText(*te, *te\cursor(), @text, Len(text), #TE_Styling_CaseCorrection | #TE_Styling_UpdateFolding | #TE_Styling_UpdateIndentation | #TE_Styling_UnfoldIfNeeded, *te\undo)
				EndIf
			EndWith
			
			;Textline_AddText(*te, *te\cursor(), @text, Len(text), #TE_Styling_CaseCorrection | #TE_Styling_UpdateFolding | #TE_Styling_UpdateIndentation | #TE_Styling_UnfoldIfNeeded, *te\undo)
		Next
		
		If GetFlag(*te, #TE_EnableSelectPastedText) = 0
			Selection_ClearAll(*te)
		EndIf
		
		*te\needScrollUpdate = #True
	EndProcedure
	
	;-
	;- ----------- SCROLL -----------
	;-
	
	Procedure Scroll_Line(*te.TE_STRUCT, *view.TE_VIEW, *cursor.TE_CURSOR, visibleLineNr, keepCursor = #True, updateGadget = #True)
		ProcedureReturnIf((*te = #Null) Or (*view = #Null) Or (*cursor = #Null) Or (IsGadget(*view\scrollBarV\gadget) = 0))
		
		Protected selection.TE_RANGE
		Protected oldScrollLineNr = *view\scroll\visibleLineNr
		Protected oldLindeNr = *cursor\position\lineNr
		Protected lineNr
		
		visibleLineNr = Clamp(visibleLineNr, 1, *te\visibleLineCount)
		*view\scroll\visibleLineNr = Min(visibleLineNr, Max(1, *te\visibleLineCount - *view\pageHeight))
		
		If updateGadget And IsGadget(*view\scrollBarV\gadget)
			SetGadgetState(*view\scrollBarV\gadget, *view\scroll\visibleLineNr)
		EndIf
		
		If keepCursor = #False
			If Textline_FromVisibleLineNr(*te, Clamp(*cursor\position\visibleLineNr, *view\scroll\visibleLineNr, *view\scroll\visibleLineNr + *view\pageHeight))
				lineNr =  ListIndex(*te\textLine()) + 1
				Cursor_Set(*cursor, *te\textLine(), lineNr, LineNr_to_VisibleLineNr(*te, lineNr), Textline_CharNrFromScreenPos(*te, *te\textLine(), *cursor\position\currentX))
				
				If lineNr <> oldLindeNr
					Selection_Clear(*te, *cursor)
				EndIf
				
				Cursor_Update(*te, *cursor, #False)
			EndIf
		EndIf
		
		*view\firstVisibleLineNr = *view\scroll\visibleLineNr
		*view\lastVisibleLineNr = Min(*view\scroll\visibleLineNr + *view\pageHeight, *te\visibleLineCount)
		
		If *view\scroll\visibleLineNr <> oldScrollLineNr
			*te\redrawMode | #TE_Redraw_All
			ProcedureReturn #True
		EndIf
		
		ProcedureReturn #False
	EndProcedure
	
	Procedure Scroll_Char(*te.TE_STRUCT, *view.TE_VIEW, charX)
		ProcedureReturnIf((*te = #Null) Or (*view = #Null) Or (IsGadget(*view\scrollBarH\gadget) = 0))
		
		
		Protected previousCharX = *view\scroll\charX
		
		If GetFlag(*te, #TE_EnableWordWrap) And *te\wordWrapSize
			*view\scroll\charX = Min(charX, Max(0, (*te\maxTextWidth % *te\wordWrapSize) - *view\pageWidth))
		Else
			*view\scroll\charX = Min(charX, Max(0, *te\maxTextWidth - *view\pageWidth))
		EndIf
		
		*view\scroll\charX = Clamp(*view\scroll\charX, 0, Int(GetGadgetAttribute(*view\scrollBarH\gadget, #PB_ScrollBar_Maximum) * *view\scrollBarH\scale))
		
		If *view\scroll\charX <> previousCharX 
			SetGadgetState(*view\scrollBarH\gadget, *view\scroll\charX / *view\scrollBarH\scale)
			*te\redrawMode | #TE_Redraw_All
			ProcedureReturn #True
		EndIf
		
		ProcedureReturn #False
	EndProcedure
	
	Procedure Scroll_HideScrollBarH(*te.TE_STRUCT, *view.TE_VIEW, isHidden)
		ProcedureReturnIf( (*te = #Null) Or (*view = #Null) Or (IsGadget(*view\scrollBarH\gadget) = 0))
		
		Protected width = *view\width
		Protected height = *view\height
		Protected lastState = *view\scrollBarH\isHidden
		
		If *view\scrollBarV\isHidden = #False
			width - *te\scrollbarWidth
		EndIf
		
		If ( (*view\scrollBarH\enabled = #TE_Scrollbar_AlwaysOn) Or (isHidden = #False)) And (*view\scrollBarH\isHidden = #True)
			; show horizontal scrollbar
			*view\scrollBarH\isHidden = #False
			ResizeGadget(*view\scrollBarV\gadget, width, 0, *te\scrollbarWidth, height - *te\scrollbarWidth)
			ResizeGadget(*view\scrollBarH\gadget, 0, height - *te\scrollbarWidth, width, *te\scrollbarWidth)
			HideGadget(*view\scrollBarH\gadget, #False)
		ElseIf (isHidden = #True) And (*view\scrollBarH\isHidden = #False)
			; hide horizontal scrollbar
			*view\scrollBarH\isHidden = #True
			ResizeGadget(*view\scrollBarV\gadget, width, 0, *te\scrollbarWidth, height)
			HideGadget(*view\scrollBarH\gadget, #True)
		Else
			ResizeGadget(*view\scrollBarV\gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, GadgetHeight(*view\canvas))
		EndIf
		
		ProcedureReturn Bool(*view\scrollBarH\isHidden <> lastState)
	EndProcedure
	
	Procedure Scroll_HideScrollBarV(*te.TE_STRUCT, *view.TE_VIEW, isHidden)
		ProcedureReturnIf( (*te = #Null) Or (*view = #Null) Or (IsGadget(*view\scrollBarV\gadget) = 0))
		
		Protected width = *view\width
		Protected height = *view\height
		Protected lastState = *view\scrollBarV\isHidden
		
		If *view\scrollBarH\isHidden = #False
			height - *te\scrollbarWidth
		EndIf
		
		If ( (*view\scrollBarV\enabled = #TE_Scrollbar_AlwaysOn) Or (isHidden = #False)) And (*view\scrollBarV\isHidden = #True)
			; show verical scrollbar
			*view\scrollBarV\isHidden = #False
			ResizeGadget(*view\scrollBarV\gadget, width - *te\scrollbarWidth, 0, *te\scrollbarWidth, height)
			ResizeGadget(*view\scrollBarH\gadget, 0, height, width - *te\scrollbarWidth, *te\scrollbarWidth)
			HideGadget(*view\scrollBarV\gadget, #False)
		ElseIf (isHidden = #True) And (*view\scrollBarV\isHidden = #False)
			; hide verical scrollbar
			*view\scrollBarV\isHidden = #True
			ResizeGadget(*view\scrollBarH\gadget, 0, height, width, *te\scrollbarWidth)
			HideGadget(*view\scrollBarV\gadget, #True)
		Else
			ResizeGadget(*view\scrollBarV\gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, GadgetHeight(*view\canvas))
		EndIf
		
		ProcedureReturn Bool(*view\scrollBarV\isHidden <> lastState)
	EndProcedure
	
	
	Procedure Scroll_Update(*te.TE_STRUCT, *view.TE_VIEW, *cursor.TE_CURSOR, previousVisibleLineNr, previousCharNr, updateNeeded = #True)
		ProcedureReturnIf((*te = #Null) Or (*view = #Null) Or (*cursor = #Null))
		ProcedureReturnIf(updateNeeded = #False)
		
		*te\needScrollUpdate = #False
		
		Protected oldScrollLineNr = *view\scroll\visibleLineNr
		Protected pos, result = #False
		
		Protected viewWidth = (*view\width - *te\font(#TE_Font_Normal)\width(' ')) * *view\zoom - *te\leftBorderOffset
		Protected viewHeight = (*view\height - *te\topBorderSize) * *view\zoom
		Protected width, height
		Protected scrollbarChanged
		Protected counter
		Protected maxTextWidth
		
		If GetFlag(*te, #TE_EnableWordWrap) And *te\wordWrapSize
			maxTextWidth = Min(*te\maxTextWidth, *te\wordWrapSize)
		Else
			maxTextWidth = *te\maxTextWidth
		EndIf
		
		Repeat
			scrollbarChanged = 0
			
			If *view\scrollBarV\isHidden
				width = viewWidth
			Else
				width = viewWidth - *te\scrollbarWidth
			EndIf
			
			If *view\scrollBarH\isHidden
				height = viewHeight
			Else
				height = viewHeight - *te\scrollbarWidth
			EndIf
			
			*view\pageHeight = Max(1, Int(height / *te\lineHeight) - 1)
			
			If *view\scrollBarV\enabled
				If (*view\scrollBarV\enabled = #TE_Scrollbar_AlwaysOn) Or (*te\visibleLineCount > *view\pageHeight + 1)
					scrollbarChanged + Scroll_HideScrollBarV(*te, *view, #False)
				Else
					scrollbarChanged + Scroll_HideScrollBarV(*te, *view, #True)
				EndIf
			EndIf
			
			*view\pageWidth = width - 1
			If *view\scrollBarH\enabled
				If (*view\scrollBarH\enabled = #TE_Scrollbar_AlwaysOn) Or (maxTextWidth > *view\pageWidth)
					scrollbarChanged + Scroll_HideScrollBarH(*te, *view, #False)
				Else
					scrollbarChanged + Scroll_HideScrollBarH(*te, *view, #True)
				EndIf
			EndIf
			
			counter + 1
		Until (scrollbarChanged = 0) Or (counter > 1)
		
		If IsGadget(*view\scrollBarV\gadget)
			SetGadgetAttribute(*view\scrollBarV\gadget, #PB_ScrollBar_Minimum, 1)
			SetGadgetAttribute(*view\scrollBarV\gadget, #PB_ScrollBar_Maximum, *te\visibleLineCount - 1)
			SetGadgetAttribute(*view\scrollBarV\gadget, #PB_ScrollBar_PageLength, *view\pageHeight)
		EndIf
		If previousVisibleLineNr <> *cursor\position\visibleLineNr
			*view\scroll\visibleLineNr = Min(*view\scroll\visibleLineNr, Max(1, *te\visibleLineCount - *view\pageHeight))
			
			pos = *cursor\position\visibleLineNr - *view\scroll\visibleLineNr
			If pos < 0
				Scroll_Line(*te, *view, *cursor, *view\scroll\visibleLineNr + pos)
			ElseIf pos > *view\pageHeight
				Scroll_Line(*te, *view, *cursor, *view\scroll\visibleLineNr + pos - *view\pageHeight)
			EndIf
			
			result = #True
		EndIf
		
		If IsGadget(*view\scrollBarH\gadget)
			SetGadgetAttribute(*view\scrollBarH\gadget, #PB_ScrollBar_Minimum, 0)
			SetGadgetAttribute(*view\scrollBarH\gadget, #PB_ScrollBar_Maximum, Max(maxTextWidth, *view\pageWidth) / *view\scrollBarH\scale)
			SetGadgetAttribute(*view\scrollBarH\gadget, #PB_ScrollBar_PageLength, *view\pageWidth / *view\scrollBarH\scale)
			
			If previousCharNr <> *cursor\position\charNr
				*view\scroll\charX = Min(*view\scroll\charX, Max(0, maxTextWidth - *view\pageWidth))
				*view\scroll\charX = Clamp(*view\scroll\charX, 0, Int(GetGadgetAttribute(*view\scrollBarH\gadget, #PB_ScrollBar_Maximum) * *view\scrollBarH\scale))
				
				Protected charX = Textline_CharNrToScreenPos(*te, *cursor\position\textline, *cursor\position\charNr)
				
				pos = charX - *view\scroll\charX
				
				If pos < *te\font(#TE_Font_Normal)\width(' ') * 4
					Scroll_Char(*te, *view, *view\scroll\charX + pos - *te\font(#TE_Font_Normal)\width(' ') * 4)
				ElseIf pos > *view\pageWidth - *te\font(#TE_Font_Normal)\width(' ')
					Scroll_Char(*te, *view, *view\scroll\charX + pos - (*view\pageWidth - *te\font(#TE_Font_Normal)\width(' ')))
					
				EndIf
				
				result = #True
			EndIf
		EndIf
		
		*view\firstVisibleLineNr = *view\scroll\visibleLineNr
		*view\lastVisibleLineNr = Min(*view\scroll\visibleLineNr + *view\pageHeight, *te\visibleLineCount)
		
		If oldScrollLineNr <> *view\scroll\visibleLineNr
			ProcedureReturn #True
		EndIf
		
		ProcedureReturn #False
	EndProcedure
	
	Procedure Scroll_UpdateAllViews(*te.TE_STRUCT, *view.TE_VIEW, *currentView.TE_VIEW, *cursor.TE_CURSOR)
		ProcedureReturnIf((*te = #Null) Or (*cursor = #Null) Or (*view = #Null))
		
		If *view = *currentView
			Scroll_Update(*te, *view, *cursor, -1, -1)
		Else
			Scroll_Update(*te, *view, *cursor, *cursor\position\visibleLineNr, -*cursor\position\charNr)
		EndIf
		
		Scroll_UpdateAllViews(*te, *view\child[0], *currentView, *cursor)
		Scroll_UpdateAllViews(*te, *view\child[1], *currentView, *cursor)
	EndProcedure
	
	
	;-
	;- ----------- FIND / REPLACE -----------
	;-
	
	Procedure Find_AddRecent(*te.TE_STRUCT, text.s, gadget, maxRecent = 10)
		ProcedureReturnIf((*te = #Null) Or (text = "") Or (IsGadget(gadget) = 0))
		
		Protected i
		
		For i = 0 To CountGadgetItems(gadget) - 1
			If GetGadgetItemText(gadget, i) = text
				SetGadgetState(gadget, i)
				
				ProcedureReturn #False
			EndIf
		Next
		
		AddGadgetItem(gadget, 0, text)
		SetGadgetState(gadget, 0)
		
		If CountGadgetItems(gadget) > maxRecent
			RemoveGadgetItem(gadget, maxRecent)
		EndIf
		
		ProcedureReturn #True
	EndProcedure
	
	Procedure Find_Next(*te.TE_STRUCT, startLineNr, startCharNr, endLineNr, endCharNr, flags)
		ProcedureReturnIf((*te = #Null) Or (*te\find\text = ""), -1)
		
		Protected find.s = *te\find\text
		Protected text.s, replace.s
		Protected *textLine.TE_TEXTLINE
		Protected *token.TE_TOKEN
		Protected charNr
		Protected textLength
		Protected findLength, typeStart, typeEnd
		Protected result = #False, error
		Protected matchFound
		Protected matchLength
		
		; temporarily disable dictionary
		Protected enableDictionary = GetFlag(*te, #TE_EnableDictionary)
		SetFlag(*te, #TE_EnableDictionary, 0)
		
		PushListPosition(*te\textLine())
		
		*textLine = Textline_FromLine(*te, startLineNr)
		findLength = Len(find)
		typeStart = TokenType(*te\parser, Asc(Left(find, 1)))
		typeEnd = TokenType(*te\parser, Asc(Right(find, 1)))
		
		If (*te\find\flags & #TE_Find_CaseSensitive) = 0
			find = LCase(find)
		EndIf
		
		While (*textLine <> #Null) And (result = #False) And (startLineNr <= endLineNr)
			text = *textLine\text
			replace = *textLine\text
			matchFound = #False
			
			If startLineNr = endLineNr
				textLength = endCharNr - findLength + 1
			Else
				textLength = Len(text) - findLength + 1
			EndIf
			
			If *te\find\flags & #TE_Find_RegEx
				
				If IsRegularExpression(#TE_Find_RegEx)
					If ExamineRegularExpression(#TE_Find_RegEx, Mid(text, startCharNr))
						If NextRegularExpressionMatch(#TE_Find_RegEx)
							matchFound = #True
							matchLength = RegularExpressionMatchLength(#TE_Find_RegEx)
							charNr = startCharNr + RegularExpressionMatchPosition(#TE_Find_RegEx) - 1
						EndIf
					EndIf
				EndIf
				
			Else
				
				If (*te\find\flags & #TE_Find_CaseSensitive) = 0
					text = LCase(text)
				EndIf
				
				For charNr = startCharNr To textLength
					error = #False
					
					If (*te\find\flags & #TE_Find_NoComments) Or (*te\find\flags & #TE_Find_NoStrings)
						If Parser_TokenAtCharNr(*te, *textLine, charNr)
							If (*te\find\flags & #TE_Find_NoComments) And Position_InsideComment(*te, startLineNr, charNr)
								error = #True
							EndIf
							If (*te\find\flags & #TE_Find_NoStrings) And Position_InsideString(*te, startLineNr, charNr)
								error = #True
							EndIf
						EndIf
					EndIf
					
					If (error = #False) And (Mid(text, charNr, findLength) = find)
						If *te\find\flags & #TE_Find_WholeWords
							If (charNr > 1) And (typeStart = TokenType(*te\parser, Asc(Mid(text, charNr - 1, 1))))
								error = #True
							EndIf
							If (charNr < textLength) And (typeEnd = TokenType(*te\parser, Asc(Mid(text, charNr + findLength, 1))))
								error = #True
							EndIf
						EndIf
						
						If error = #False
							matchFound = #True
							matchLength = findLength
							
							Break
						EndIf
					EndIf
				Next
			EndIf
			
			If matchFound
				If (startLineNr = endLineNr) And ( (charNr + matchLength - 1) > endCharNr)
				Else
					Folding_UnfoldTextline(*te, ListIndex(*te\textLine()) + 1)
  					Cursor_Position(*te, *te\currentCursor, startLineNr, charNr + matchLength, #False, #False)
					Selection_SetRange(*te, *te\currentCursor, startLineNr, charNr, #False)
					
					*te\find\startPos\lineNr = startLineNr
					*te\find\startPos\charNr = charNr + matchLength
					
					If (flags & #TE_Find_ReplaceAll) Or (flags & #TE_Find_Replace)
						If find <> *te\find\replace
							Selection_Delete(*te, *te\currentCursor, *te\undo)
							Textline_AddText(*te, *te\currentCursor, @*te\find\replace, Len(*te\find\replace), #TE_Styling_CaseCorrection | #TE_Styling_UpdateFolding | #TE_Styling_UpdateIndentation, *te\undo)
							
							If startLineNr = endLineNr
								*te\find\endPos\charNr + (Len(*te\find\replace) - matchLength)
							EndIf
						EndIf
						*te\find\replaceCount + 1
					EndIf
					
					result = startLineNr
				EndIf
			EndIf
			
			startCharNr = 1
			
			If flags & #TE_Find_Previous
				startLineNr - 1
				*textLine = PreviousElement(*te\textLine())
			Else
				startLineNr + 1
				*textLine = NextElement(*te\textLine())
			EndIf
		Wend
		
		PopListPosition(*te\textLine())
		
		setFlag(*te, #TE_EnableDictionary, enableDictionary)
		
		ProcedureReturn result
	EndProcedure	
	
	Procedure Find_Start(*te.TE_STRUCT, *cursor.TE_CURSOR, startLineNr, startCharNr, find.s, replace.s, flags)
		ProcedureReturnIf((*te = #Null) Or (*cursor = #Null) Or (find = ""))
		
		Protected selection.TE_RANGE
		Protected result
		
		Cursor_Clear(*te, *cursor)
		Selection_Get(*cursor, selection)
		
		If (flags & #TE_Find_InsideSelection) And Selection_IsAnythingSelected(*te)
			startLineNr = selection\pos1\lineNr
			startCharNr = selection\pos1\charNr
			*te\find\endPos\lineNr = selection\pos2\lineNr
			*te\find\endPos\charNr = selection\pos2\charNr - 1
		EndIf
		
		If flags & #TE_Find_ReplaceAll
			
			If (flags & #TE_Find_InsideSelection) = 0
				startLineNr = 1
				startCharNr = 1
				*te\find\endPos\lineNr = ListSize(*te\textLine())
				*te\find\endPos\charNr = Textline_Length(LastElement(*te\textLine()))
			EndIf
			
		ElseIf flags & #TE_Find_StartAtCursor
			
			If Selection_IsAnythingSelected(*te)
				startLineNr = selection\pos1\lineNr
				startCharNr = selection\pos1\charNr
			Else
				startLineNr = *cursor\position\lineNr
				startCharNr = *cursor\position\charNr
			EndIf
			
			If (startLineNr = *te\find\startPos\lineNr) And (startCharNr = *te\find\startPos\charNr)
				If Selection_IsAnythingSelected(*te)
					startLineNr = selection\pos2\lineNr
					startCharNr = selection\pos2\charNr
				Else
					startCharNr + 1
				EndIf
			EndIf
			
			*te\find\endPos\lineNr = ListSize(*te\textLine())
			*te\find\endPos\charNr = Textline_Length(LastElement(*te\textLine()))
		EndIf
		
		*te\find\text = find
		*te\find\replace = replace
		*te\find\replaceCount = 0
		*te\find\flags = Find_Flags(*te)
		
		If *te\find\flags & #TE_Find_RegEx
			If IsRegularExpression(*te\regExFind)
				FreeRegularExpression(*te\regExFind)
			EndIf
			
			*te\regExFind = CreateRegularExpression(#PB_Any, GetGadgetText(*te\find\cmb_search))
			If IsRegularExpression(*te\regExFind) = 0
				MessageRequester(*te\language\errorTitle, *te\language\errorRegEx + ":" + #CRLF$ + RegularExpressionError(), #PB_MessageRequester_Error)
				ProcedureReturn 0
			EndIf
		EndIf
		
		result = Find_Next(*te, startLineNr, startCharNr, *te\find\endPos\lineNr, *te\find\endPos\charNr, flags)
		
		If result
			Find_AddRecent(*te, find, *te\find\cmb_search)
			
			If (flags & #TE_Find_Replace) Or (flags & #TE_Find_ReplaceAll)
				Find_AddRecent(*te, replace, *te\find\cmb_replace)
			EndIf
			
			If (flags & #TE_Find_ReplaceAll) = 0
				Scroll_Update(*te, *te\currentView, *cursor, result - 3, *cursor\position\charNr)
				Scroll_Line(*te, *te\currentView, *cursor, LineNr_to_VisibleLineNr(*te, result - 3))
				
				SyntaxHighlight_Update(*te)
				
				If Selection_Get(*cursor, selection)
					RepeatedSelection_Update(*te, selection\pos1\lineNr, selection\pos1\charNr, selection\pos2\lineNr, selection\pos2\charNr)
				EndIf
				*te\redrawMode = #TE_Redraw_All
			EndIf
			
		ElseIf (result = #False) And (flags & #TE_Find_ReplaceAll = 0)
			
			If flags & #TE_Find_Previous
				If MessageRequester(*te\language\messageTitleFindReplace, *te\language\messageNoMoreMatchesEnd, #PB_MessageRequester_Info | #PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
					*te\find\endPos\lineNr = ListSize(*te\textLine())
					*te\find\endPos\charNr = Textline_Length(LastElement(*te\textLine()))
					
					result = Find_Next(*te, ListSize(*te\textLine()), Textline_Length(LastElement(*te\textLine())), *te\find\endPos\lineNr, *te\find\endPos\charNr, flags)
					If result = #False
						MessageRequester(*te\language\messageTitleFindReplace, *te\language\messageNoMoreMatches)
					EndIf
				EndIf
			Else
				If MessageRequester(*te\language\messageTitleFindReplace, *te\language\messageNoMoreMatchesStart, #PB_MessageRequester_Info | #PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
					*te\find\endPos\lineNr = ListSize(*te\textLine())
					*te\find\endPos\charNr = Textline_Length(LastElement(*te\textLine()))
					
					result = Find_Next(*te, 1, 1, *te\find\endPos\lineNr, *te\find\endPos\charNr, flags)
					If result = #False
						MessageRequester(*te\language\messageTitleFindReplace, *te\language\messageNoMoreMatches)
					EndIf
				EndIf
			EndIf
		EndIf
		
		If *te\needFoldUpdate
			Folding_Update(*te, -1, -1)
		EndIf
		
		Cursor_SignalChanges(*te, *te\currentCursor)
		Autocomplete_UpdateDictonary(*te, 0, 0)
		
		ProcedureReturn result
	EndProcedure
	
	Procedure Find_Show(*te.TE_STRUCT, text.s, replace = #False)
		ProcedureReturnIf((*te = #Null) Or (IsWindow(*te\find\wnd_findReplace) = 0))
		
		Protected *view.TE_VIEW = *te\currentView
		
		If (text <> "") And (IsGadget(*te\find\chk_regEx) And (GetGadgetState(*te\find\chk_regEx) = 0))
			SetGadgetText(*te\find\cmb_search, text)
		EndIf
		
		ResizeWindow(*te\find\wnd_findReplace, 
		             GadgetX(*view\canvas, #PB_Gadget_ScreenCoordinate) + (*view\width - WindowWidth(*te\find\wnd_findReplace)) / 2, 
		             GadgetY(*view\canvas, #PB_Gadget_ScreenCoordinate) + (*view\height - WindowHeight(*te\find\wnd_findReplace)) / 2, 
		             #PB_Ignore, #PB_Ignore)
		
		HideWindow(*te\find\wnd_findReplace, 0)
		SetActiveWindow(*te\find\wnd_findReplace)
		
		If replace
			SetGadgetState(*te\find\chk_replace, 1)
			DisableGadget(*te\find\cmb_replace, 0)
			DisableGadget(*te\find\btn_replace, 0)
			DisableGadget(*te\find\btn_replaceAll, 0)
			SetActiveGadget(*te\find\cmb_replace)
		Else
			SetGadgetState(*te\find\chk_replace, 0)
			DisableGadget(*te\find\cmb_replace, 1)
			DisableGadget(*te\find\btn_replace, 1)
			DisableGadget(*te\find\btn_replaceAll, 1)
			SetActiveGadget(*te\find\cmb_search)
		EndIf

		
		
		*te\find\isVisible = #True
	EndProcedure
	
	Procedure Find_Close(*te.TE_STRUCT)
		ProcedureReturnIf((*te = #Null) Or (IsWindow(*te\find\wnd_findReplace) = 0))
		
		HideWindow(*te\find\wnd_findReplace, #True)
		SetActiveWindow(*te\window)
		SetActiveGadget(*te\currentView\canvas)
		
		*te\find\isVisible = #False
	EndProcedure
	
	Procedure Find_Flags(*te.TE_STRUCT)
		ProcedureReturnIf(*te = #Null)
		
		Protected flags
		
		If IsGadget(*te\find\chk_caseSensitive) And GetGadgetState(*te\find\chk_caseSensitive)
			flags | #TE_Find_CaseSensitive
		EndIf
		If IsGadget(*te\find\chk_wholeWords) And GetGadgetState(*te\find\chk_wholeWords)
			flags | #TE_Find_WholeWords
		EndIf
		If IsGadget(*te\find\chk_noComments) And GetGadgetState(*te\find\chk_noComments)
			flags | #TE_Find_NoComments
		EndIf
		If IsGadget(*te\find\chk_noStrings) And GetGadgetState(*te\find\chk_noStrings)
			flags | #TE_Find_NoStrings
		EndIf
		If IsGadget(*te\find\chk_insideSelection) And GetGadgetState(*te\find\chk_insideSelection)
			flags | #TE_Find_InsideSelection
		EndIf
		If IsGadget(*te\find\chk_regEx) And GetGadgetState(*te\find\chk_regEx)
			flags | #TE_Find_RegEx
		EndIf
		
		ProcedureReturn flags
	EndProcedure
	
	Procedure Find_SetSelectionCheckbox(*te.TE_STRUCT)
		ProcedureReturnIf((*te = #Null) Or IsGadget(*te\find\chk_insideSelection) = 0)
		
		If Selection_IsAnythingSelected(*te)
			DisableGadget(*te\find\chk_insideSelection, #False)
		Else
			DisableGadget(*te\find\chk_insideSelection, #True)
		EndIf
	EndProcedure
	
	;-
	;- ----------- AUTOCOMPLETE -----------
	;-
	
	Procedure Autocomplete_Hide(*te.TE_STRUCT)
		ProcedureReturnIf(*te = #Null)
		
		If *te\autoComplete\isVisible
			*te\autoComplete\isVisible = #False
			*te\autoComplete\isScrollBarVisible = #False
			*te\autoComplete\isScrolling = #False
			*te\redrawMode = #TE_Redraw_All
		EndIf
	EndProcedure
	
	Procedure Autocomplete_Show(*te.TE_STRUCT)
		ProcedureReturnIf((*te = #Null) Or GetFlag(*te, #TE_EnableReadOnly) Or (GetFlag(*te, #TE_EnableAutoComplete) = 0))
		
		Protected *view.TE_VIEW = *te\currentView
		Protected *cursor.TE_CURSOR = *te\currentCursor
		Protected lText.s, textLen, AutocompleteCount
		Protected tokenIndex
		Protected *token.TE_TOKEN
		Protected *prevToken.TE_TOKEN
		Protected style
		Protected addKeywords = #True
		Protected nrRows = *te\autoComplete\rows
		
		ClearList(*te\autoComplete\entry())
		
		*te\autoComplete\text = ""
		*te\autoComplete\isScrolling = #False
		*te\autoComplete\lastKeyword = ""
		
		If *cursor = #Null
			ProcedureReturn #False
		ElseIf Style_FromCharNr(*cursor\position\textline, *cursor\position\charNr, #True) = #TE_Style_Comment
			ProcedureReturn #False
		ElseIf Parser_InsideStructure(*te, *cursor\position\textline, *cursor\position\charNr - 1)
			addKeywords = #False
		EndIf
		
		If Parser_TokenAtCharNr(*te, *cursor\position\textline, *cursor\position\charNr - 1)
			*token = *te\parser\token
			
			If Parser_NextToken(*te, -1, 0)
				*prevToken = *te\parser\token
				; 				If *prevToken\type = #TE_Token_Backslash
				; 					addKeywords = #False
				; 					lText = "\"
				If *prevToken\type = #TE_Token_Unknown And *prevToken\text\c = '#'
					addKeywords = #False
					*te\autoComplete\text = "#"
				ElseIf *prevToken\type = #TE_Token_Operator And *prevToken\text\c = '*'
					addKeywords = #False
					*te\autoComplete\text = "*"
				EndIf
			EndIf
			
			If (*token\type = #TE_Token_Text) Or (*token\type = #TE_Token_Unknown)
				*te\autoComplete\text + Left(TokenText(*token), *cursor\position\charNr - *token\charNr)
				lText = LCase(*te\autoComplete\text)
				textLen = Len(lText)
			EndIf
		EndIf
		
		If (textLen < *te\autocomplete\minCharacterCount)
			Autocomplete_Hide(*te.TE_STRUCT)
			ProcedureReturn #False
		EndIf
		
		If addKeywords
			ForEach *te\keyWord()
				If *te\autocomplete\mode = #TE_Autocomplete_FindAtBegind
					If Len(*te\keyWord()\name) >= textLen
						If Left(LCase(*te\keyWord()\name), textLen) = lText
							If AddElement(*te\autoComplete\entry())
								*te\autoComplete\entry()\name = *te\keyWord()\name
								*te\autoComplete\entry()\length = Len(*te\keyWord()\name)
							EndIf
						EndIf
					EndIf
				ElseIf *te\autocomplete\mode = #TE_Autocomplete_FindAny
					If FindString(LCase(*te\keyWord()\name), lText)
						If AddElement(*te\autoComplete\entry())
							*te\autoComplete\entry()\name = *te\keyWord()\name
							*te\autoComplete\entry()\length = Len(*te\keyWord()\name)
						EndIf
					EndIf
				EndIf
			Next
		EndIf
		
		ForEach *te\dictionary()
			If (Len(*te\dictionary()) >= textLen)
				If (Left(LCase(*te\dictionary()), textLen) = lText)
					If AddElement(*te\autoComplete\entry())
						*te\autoComplete\entry()\name = *te\dictionary()
						*te\autoComplete\entry()\length = Len(*te\dictionary())
					EndIf
				EndIf
			EndIf
		Next
		
		If ListSize(*te\autoComplete\entry()) = 0
			Autocomplete_Hide(*te.TE_STRUCT)
		Else
			; 			If *te\autoComplete\mode = #TE_Autocomplete_FindAtBegind
			; 				SortStructuredList(*te\autoComplete\entry(), #PB_Sort_Ascending, OffsetOf(TE_KEYWORDITEM\length), #PB_Long)
			; 			Else
			SortStructuredList(*te\autoComplete\entry(), #PB_Sort_Ascending, OffsetOf(TE_KEYWORDITEM\name), #PB_String)
			; 			EndIf
			
			With *te\autoComplete
				\width = 0
				If IsGadget(*te\currentView\canvas) And StartVectorDrawing(CanvasVectorOutput(*te\currentView\canvas))
					VectorFont(*te\font(#TE_Font_Normal)\id)
					ForEach \entry()
						\width = Max(\width, VectorTextWidth(\entry()\name) + 10)
					Next
					\width = min(\width + \scrollBarWidth, 350)
					\rows = Min(\maxRows, ListSize(\entry()))
					\x = Textline_CharNrToScreenPos(*te, *cursor\position\textline, *cursor\position\charNr - textLen) - *view\scroll\charX + *te\leftBorderOffset
					\x = Clamp(\x, *te\leftBorderOffset, DesktopUnscaledX(VectorOutputWidth()) - \width - 5)
					\y = (*cursor\position\visibleLineNr - *view\scroll\visibleLineNr + 1) * *te\lineHeight + *te\topBorderSize + 2
					
					Protected yHeight = (*cursor\position\visibleLineNr - *view\scroll\visibleLineNr + \rows) - *view\pageHeight
					If yHeight > 0
						yHeight = *view\pageHeight - (*cursor\position\visibleLineNr - *view\scroll\visibleLineNr)
						If yHeight > 2
							\rows = yHeight
						Else
							\y - (\rows + 1) * *te\lineHeight - 4
						EndIf
					EndIf
					
					\height = \rows * *te\lineHeight
					\index = 0
					\scrollLine = 0
					\isVisible = #True
					\isScrollBarVisible = Bool(ListSize(\entry()) > \rows)
					
					
					ForEach *te\autoComplete\entry()
						If *te\autoComplete\entry()\name = *te\autoComplete\keyword
							*te\autoComplete\index = ListIndex(*te\autoComplete\entry())
							If *te\autoComplete\index > *te\autoComplete\maxRows
								*te\autoComplete\scrollLine - (*te\autoComplete\index - *te\autoComplete\maxRows + 1)
							EndIf
							Break
						EndIf
					Next
					
					StopVectorDrawing()
				EndIf
			EndWith
		EndIf
		
		If nrRows <> *te\autoComplete\rows
			*te\redrawMode = #TE_Redraw_All
		EndIf
		
		ProcedureReturn *te\autoComplete\rows
	EndProcedure
	
	Procedure Autocomplete_InsertClosingKeyword(*te.TE_STRUCT, *cursor.TE_CURSOR, keyword.s)
		ProcedureReturnIf((*te = #Null) Or (GetFlag(*te, #TE_EnableAutoClosingKeyword) = 0))
		
		Protected result
		Protected charNr = *cursor\position\charNr
		Protected *syntax.TE_SYNTAX= FindMapElement(*te\syntax(), LCase(keyword))
		If *syntax
			If *syntax\flags & #TE_Syntax_Start
				ForEach *syntax\after()
					If *te\syntax(LCase(*syntax\after()\keyword))\flags & #TE_Syntax_End
						keyword = *syntax\after()\keyword
						result + Textline_AddText(*te, *cursor, @keyword, Len(keyword), #TE_Styling_CaseCorrection | #TE_Styling_UpdateFolding | #TE_Styling_UpdateIndentation, *te\undo)
						Cursor_Position(*te, *cursor, *cursor\position\lineNr, charNr)
						Break
					EndIf
				Next
			EndIf
		EndIf
		
		ProcedureReturn result
	EndProcedure
	
	Procedure Autocomplete_Insert(*te.TE_STRUCT)
		ProcedureReturnIf(*te = #Null Or ListSize(*te\autoComplete\entry()) = 0)
		
		Protected result = #False
		Protected *cursor.TE_CURSOR
		Protected index = Clamp(*te\autoComplete\index, 0, ListSize(*te\autoComplete\entry()) - 1)
		Protected autocomplete.s
		
		If SelectElement(*te\autoComplete\entry(), index)
			
			autocomplete = *te\autoComplete\entry()\name
			
			If FindMapElement(*te\syntax(), LCase(autocomplete))
				If *te\syntax()\flags & #TE_Syntax_Start
					*te\autoComplete\lastKeyword = autocomplete
				EndIf
			EndIf
			
			If autocomplete
				*te\autoComplete\keyword = autocomplete
				
				PushListPosition(*te\cursor())
				ForEach *te\cursor()
					*cursor = *te\cursor()
					
					Selection_SetRange(*te, *cursor, *cursor\position\lineNr, *cursor\position\charNr - Len(*te\autoComplete\text), #False)
					Selection_Delete(*te, *cursor, *te\undo)
					result + Textline_AddText(*te, *cursor, @autocomplete, Len(autocomplete), #TE_Styling_CaseCorrection | #TE_Styling_UpdateFolding | #TE_Styling_UpdateIndentation, *te\undo)
					
					*cursor\position\currentX = Textline_CharNrToScreenPos(*te, *cursor\position\textline, *cursor\position\charNr)
				Next
				PopListPosition(*te\cursor())
				
			EndIf
		EndIf
		
		Autocomplete_Hide(*te.TE_STRUCT)
		
		ProcedureReturn result
	EndProcedure
	
	Procedure Autocomplete_UpdateDictonary(*te.TE_STRUCT, startLineNr = 0, endLineNr = 0)
		ProcedureReturnIf((*te = #Null) Or (GetFlag(*te, #TE_EnableDictionary) = 0))
		ProcedureReturnIf(IsRegularExpression(*te\regExDictionary) = 0)
		
		*te\needDictionaryUpdate = #False
		
		Protected key.s, matchString.s
		Protected *token.TE_TOKEN, *prevToken.TE_TOKEN
		Protected selection.TE_RANGE
		Protected textAtCursor.s
		
		If Selection_WholeWord(*te, *te\currentCursor, *te\currentCursor\position\lineNr, *te\currentCursor\position\charNr - 1, @selection)
			textAtCursor = text_Get(*te, selection\pos1\lineNr, selection\pos1\charNr, selection\pos2\lineNr, selection\pos2\charNr)
		EndIf
		
		If endLineNr = 0
			endLineNr = ListSize(*te\textLine())
		EndIf
		
		startLineNr = Max(startLineNr, 1)
		endLineNr = Max(endLineNr, 1)
		
		Protected text.s = Text_Get(*te, startLineNr, 1, endLineNr, Textline_LastCharNr(*te, endLineNr))
		
		ClearMap(*te\dictionary())
		
		If ExamineRegularExpression(*te\regExDictionary, text)
			While NextRegularExpressionMatch(*te\regExDictionary)
				matchString = RegularExpressionMatchString(*te\regExDictionary)
				If matchString <> textAtCursor
					key = LCase(matchString)
					If FindMapElement(*te\keyWord(), key) = 0
						*te\dictionary(key) = matchString
					EndIf
				Else
					textAtCursor = ""
				EndIf
			Wend
		EndIf
		
		ProcedureReturn 1
	EndProcedure
	
	Procedure Autocomplete_Scroll(*te.TE_STRUCT, direction, scrollPosition.d = 0)
		ProcedureReturnIf(*te = #Null)
		
		If direction = 0
			*te\autoComplete\scrollLine = -Clamp(scrollPosition * ListSize(*te\autoComplete\entry()), 0, ListSize(*te\autoComplete\entry()) - *te\autoComplete\rows )
		Else
			Protected newIndex = *te\autoComplete\index + *te\autoComplete\scrollLine + direction
			
			*te\autoComplete\index = Clamp(*te\autoComplete\index + direction, 0, ListSize(*te\autoComplete\entry()) - 1)
			If direction < 0 And newIndex < 0
				*te\autoComplete\scrollLine = Min(*te\autoComplete\scrollLine - direction, 0)
			ElseIf direction > 0 And newIndex >= *te\autoComplete\rows
				*te\autoComplete\scrollLine = Max(*te\autoComplete\scrollLine - direction, *te\autoComplete\rows - ListSize(*te\autoComplete\entry()))
			EndIf
			
			Protected line = *te\autoComplete\index + *te\autoComplete\scrollLine
			If (line < 0) Or (line >= *te\autoComplete\maxRows)
				*te\autoComplete\scrollLine = -Clamp(*te\autoComplete\index, 0, ListSize(*te\autoComplete\entry()) - *te\autoComplete\maxRows)
			EndIf
			
		EndIf
	EndProcedure
	
	;-
	;- ----------- REMARK -----------
	;-	
	
	Procedure Remark_Clear(*te.TE_STRUCT, *selection.TE_RANGE = #Null)
		ProcedureReturnIf(*te = #Null)
		
		Protected *textLine.TE_TEXTLINE
		Protected lineNr, endLineNr, removedRemarkCount
		
		If *selection
			lineNr = *selection\pos1\lineNr
			endLineNr = *selection\pos2\lineNr
		Else
			lineNr = 1
			endLineNr = ListSize(*te\textLine())
		EndIf
		
		If Textline_FromLine(*te, endLineNr)
			Repeat
				If *te\textLine()\remark
					Textline_DeleteRemark(*te, *textLine, *te\undo)
				EndIf
			Until (PreviousElement(*te\textLine()) = #Null) Or (ListIndex(*te\textLine()) < lineNr)
		EndIf
		
		ProcedureReturn removedRemarkCount
	EndProcedure
	
	Procedure Remark_IsSelected(*te.TE_STRUCT, lineNr, endLineNr)
		ProcedureReturnIf(*te = #Null)
		
		Protected result = #False
		
		PushListPosition(*te\textLine())
		If Textline_FromLine(*te, lineNr)
			Repeat
				If *te\textLine()\remark
					result = #True
					Break
				EndIf
			Until (NextElement(*te\textLine()) = #Null) Or (ListIndex(*te\textLine()) >= endLineNr)
		EndIf
		PopListPosition(*te\textLine())
		
		ProcedureReturn result
	EndProcedure
	
	;-
	;- ----------- MARKER -----------
	;-	
	
	Procedure Marker_Add(*te.TE_STRUCT, *textline.TE_TEXTLINE, markerType)
		ProcedureReturnIf((*te = #Null) Or (*textline = #Null))
		
		If *textline\marker & markerType
			*textline\marker & ~markerType
		Else
			*textline\marker | markerType
		EndIf
		*textline\needRedraw = #True
		
		*te\redrawMode | #TE_Redraw_ChangedLines
		
		ProcedureReturn #True
	EndProcedure
	
	Procedure Marker_ClearAll(*te.TE_STRUCT)
		ProcedureReturnIf(*te = #Null)
		Protected result = #False
		
		ForEach *te\textLine()
			If *te\textLine()\marker
				*te\textLine()\marker = 0
				*te\textLine()\needRedraw = #True
				result = #True
			EndIf
		Next
		
		If result
			*te\redrawMode | #TE_Redraw_ChangedLines
		EndIf
		
		ProcedureReturn result
	EndProcedure
	
	Procedure Marker_Jump(*te.TE_STRUCT, markerType)
		ProcedureReturnIf(*te = #Null)
		
		Protected *currentLine.TE_TEXTLINE = *te\currentcursor\position\textline
		Protected lineNr = 0
		
		ChangeCurrentElement(*te\textLine(), *te\currentcursor\position\textline)
		
		While (lineNr = 0) And NextElement(*te\textLine())
			If *te\textLine()\marker & markerType
				lineNr = ListIndex(*te\textLine()) + 1
			EndIf
		Wend
		
		If lineNr = 0
			ForEach *te\textLine()
				If *te\textLine() = *currentLine
					Break
				ElseIf *te\textLine()\marker & markerType
					lineNr = ListIndex(*te\textLine()) + 1
					Break
				EndIf
			Next
		EndIf
		
		Debug lineNr
		
		If lineNr
			Folding_UnfoldTextline(*te, lineNr)
			Cursor_Position(*te, *te\currentCursor, lineNr, 1)
			Scroll_Line(*te, *te\currentView, *te\currentCursor, *te\currentCursor\position\visibleLineNr)
			ProcedureReturn #True
		Else
			ChangeCurrentElement(*te\textLine(), *currentLine)
			ProcedureReturn #False
		EndIf
	EndProcedure
	
	;-
	;- ----------- DRAW -----------
	;-
	
	Macro Draw_RoundBox(x_, y_, width_, height_, radius_, corners_, color_, fillColor_ = #TE_Ignore, lineWidth_ = #TE_VectorDrawWidth)
		MovePathCursor(x_ + radius_, y_)
		AddPathArc(x_ + width_, y_, x_ + width_, y_ + height_, radius_)
		AddPathArc(x_ + width_, y_ + height_, x_  , y_ + height_, radius_)
		AddPathArc(x_, y_ + height_, x_  , y_  , radius_)
		AddPathArc(x_, y_, x_ + radius_, y_  , radius_)
		ClosePath()
		
		If fillColor_ <> #TE_Ignore
			VectorSourceColor(fillColor_)
			FillPath(#PB_Path_Preserve)
		EndIf
		
		If color_ <> #TE_Ignore
			VectorSourceColor(color_)
			StrokePath(lineWidth_, #PB_Path_RoundCorner)
		EndIf
		ResetPath()
	EndMacro
	
	Macro Draw_Box(x_, y_, width_, height_, color_, fillColor_ = #TE_Ignore, lineWidth_ = #TE_VectorDrawWidth)
		If fillColor_ <> #TE_Ignore
			AddPathBox(x_, y_, width_, height_)
			VectorSourceColor(fillColor_)
			FillPath()
		EndIf
		If color_ <> #TE_Ignore And lineWidth_ > 0
			AddPathBox(x_, y_, width_, height_)
			VectorSourceColor(color_)
			StrokePath(lineWidth_)
		EndIf
		ResetPath()
	EndMacro
	
	Macro Draw_Circle(x_, y_, radius_, color_, fillColor_ = #TE_Ignore)
		If fillColor_ <> #TE_Ignore
			VectorSourceColor(fillColor_)
			AddPathCircle(x_, y_, radius_)
			FillPath(#PB_Path_Preserve)
		EndIf
		If color_ <> #TE_Ignore
			VectorSourceColor(color_)
			AddPathCircle(x_, y_, radius_)
			StrokePath(#TE_VectorDrawWidth)
		EndIf
		
		ResetPath()
	EndMacro
	
	Macro Draw_Line(x1_, y1_, width_, height_, color_, lineWidth_ = #TE_VectorDrawWidth)
		MovePathCursor(x1_, y1_)
		AddPathLine(width_, height_, #PB_Path_Relative)
		
		VectorSourceColor(color_)
		StrokePath(lineWidth_, #PB_Path_RoundEnd)
	EndMacro
	
	Macro Draw_DotLine(x1_, y1_, x2_, y2_, width_, distance_, color_)
		VectorSourceColor(color_)
		MovePathCursor(x1_, y1_)
		AddPathLine(x2_, y2_, #PB_Path_Relative)
		DotPath(width_, distance_, #PB_Path_RoundEnd)
	EndMacro
	
	Procedure.d Draw_Text(*te.TE_STRUCT, x.d, y.d, text.s, textColor, fillColor = #TE_Ignore, lineWidth.d = 0, width.d = 0)
		ProcedureReturnIf(text = "")
		
		If fillColor <> #TE_Ignore Or width
			width = VectorTextWidth(text)
		EndIf
		
		If fillColor <> #TE_Ignore
			Protected height.d = VectorTextHeight(text)
			Draw_Box(x, y, width, height, textColor, fillColor, lineWidth)
		EndIf
		
		MovePathCursor(x, y)
		VectorSourceColor(textColor)
		DrawVectorText(text)
		
		ProcedureReturn width
	EndProcedure
	
	Procedure Draw_DragText(*te.TE_STRUCT, x.d, y.d)
		ProcedureReturnIf(*te = #Null)
		
		Protected width = VectorTextWidth(*te\cursorState\dragTextPreview)
		Protected height = VectorTextHeight(*te\cursorState\dragTextPreview)
		x = Clamp(x + 10, *te\leftBorderOffset + 10, *te\currentView\x + *te\currentView\width - (width + 2))
		y = Clamp(y - height - 10, *te\topBorderSize, *te\currentView\y + *te\currentView\height - (height + 2))
		
		; 		Draw_Box(x - 1, y - 1, width + 2, height + 2, RGBA(255, 255, 255, 64), RGBA(64, 64, 64, 64))
		Draw_Box(x - 1, y - 1, width + 2, height + 2, RGBA(255, 255, 255, 64), RGBA(64, 64, 64, 128))
		Draw_Text(*te, x, y, *te\cursorState\dragTextPreview, RGBA(255, 255, 255, 255))
	EndProcedure
	
	Procedure Draw_WhiteSpace(x.d, y.d, width.d, height.d, char, color)
		Protected h2.d, w2.d, w3
		
		Draw_Box(x, y, width - 1, height - 1, color, #TE_Ignore, 0.5)
		If char = ' '
			Draw_Box(x + width / 2 - 1, y + height / 2, 1, 1, color)
		ElseIf char = #TAB
			h2 = Max(1, height * 0.2)
			w2 = Max(1, width - 3)
			w3 = Max(width * 0.5, width - height)
			x = x + 2
			y = y + height / 2
			Draw_Line(x, y, w2, 0, color, 0.5)
			Draw_Line(x + w2, y, -w3, -h2, color, 0.5)
			Draw_Line(x + w2, y, -w3, h2, color, 0.5)
		EndIf
	EndProcedure
	
	Procedure Draw_FoldIcon(*te.TE_STRUCT, x.d, y.d, size.d, size2.d, foldState)
		Protected sizeH = size / 2
		
		Draw_Box(x - sizeH, y - sizeH, sizeH * 2, sizeH * 2, *te\colors\foldIconBorder, *te\colors\lineNrBackground)
		;		Draw_Circle(x, y, sizeH, *te\colors\foldIconBorder)
		
		Draw_Line(x - sizeH + 2, y, size - 4, 0, *te\colors\foldIcon)
		If foldState = #TE_Folding_Folded
			Draw_Line(x, y - sizeH + 2, 0, size - 4, *te\colors\foldIcon)
		Else
			Draw_Line(x, y + sizeH, 0, size2 - size - 3, *te\colors\foldIconBorder)
		EndIf
	EndProcedure
	
	Procedure Draw_Marker(*te.TE_STRUCT, x.d, y.d, style)
		Protected h = *te\lineHeight - 2
		Protected w = *te\lineHeight / 2
		
		If style & #TE_Marker_Breakpoint
			Draw_Box(x, y, BorderSize(*te) - h + 2, h, RGBA(255, 128, 128, 255), RGBA(128, 0, 0, 255))
		EndIf
		
		If style & #TE_Marker_Bookmark
			MovePathCursor(x - 1, y + 2)
			AddPathLine( w, 0, #PB_Path_Relative)
			AddPathLine( -w / 2, h / 2 - 2, #PB_Path_Relative)
			AddPathLine( w / 2, h / 2 - 2, #PB_Path_Relative)
			AddPathLine( -w, 0, #PB_Path_Relative)
			ClosePath()
			VectorSourceColor(RGBA( 0, 200, 0, 255))
			FillPath(#PB_Path_Preserve)
			VectorSourceColor(RGBA(255, 255, 255, 255))
			StrokePath(1)
		EndIf
	EndProcedure
	
	Procedure Draw_Cursor(*te.TE_STRUCT, x.d, y.d, width.d, height.d, cursorType, isCurrentCursor.a)
		ProcedureReturnIf(*te = #Null)
		
		Protected cursorWidth.d = 1
		If isCurrentCursor
			cursorWidth = 2.5
		EndIf
		
		If cursorType = #TE_Cursor_Normal
			If *te\cursorState\overwrite
				Draw_Line(x, y + height - 2, width, 0, *te\colors\cursor, cursorWidth)
			Else
				Draw_Line(x + #TE_VectorDrawWidth, y + 1.75, 0, height - 3.5, *te\colors\cursor, cursorWidth)
			EndIf
		ElseIf cursorType = #TE_Cursor_DragDrop Or cursorType = #TE_Cursor_DragDropForbidden
			
			If cursorType = #TE_Cursor_DragDropForbidden
				Draw_DotLine(x, y + 3, 0, height, 3, 6, RGBA(255,0,0,255))
			Else
				Draw_DotLine(x, y + 3, 0, height, 3, 6, *te\colors\cursor)
			EndIf
			
			If *te\cursorState\dragDropMode = #TE_CursorState_DragCopy
				Protected w.d = height * 0.5
				Protected h.d = w * 0.5
				
				Draw_Box(x + h, y, w, w, *te\colors\cursor, *te\colors\currentBackground)
				Draw_Line(x + h + h, y + 2, 0, w - 4, *te\colors\cursor)
				Draw_Line(x + h + 2, y + h, w - 4, 0, *te\colors\cursor)
			EndIf
		EndIf
	EndProcedure
	
	Procedure Draw_LeftBorder(*te.TE_STRUCT, *textline.TE_TEXTLINE, lineNr, x, y, *cursor.TE_CURSOR)
		ProcedureReturnIf((*te = #Null) Or (*textline = #Null))
		
		Protected foldiconSize = FoldiconSize(*te)
		Protected xFoldLine = *te\leftBorderOffset - (*te\lineHeight * 0.5) + 1
		Protected height = *te\lineHeight
		Protected *font.TE_FONT = @*te\font(#TE_Font_Normal)
		Protected color, backgroundColor
		
		If GetFlag(*te, #TE_EnableLineNumbers)
			backgroundColor =*te\colors\lineNrBackground
			
			If GetFlag(*te, #TE_EnableShowCurrentLine) And *cursor And (lineNr = *cursor\position\lineNr)
				color = *te\colors\currentLineNr
			Else
				color = *te\colors\lineNr
			EndIf
			
			Draw_Box(0, y, *te\leftBorderOffset - *te\lineHeight - #TE_VectorDrawWidth, height, *te\colors\lineNrBackground, backgroundColor)
			Draw_Box(*te\leftBorderOffset - *te\lineHeight, y, *te\lineHeight - #TE_VectorDrawWidth, height, *te\colors\foldIconBackground, *te\colors\foldIconBackground)
		EndIf
		
		If *te\textLine()\marker
			Draw_Marker(*te, 0, y, *te\textLine()\marker)
		EndIf
		
		If *font\id And GetFlag(*te, #TE_EnableLineNumbers) And (*textline\remark = #Null)
			VectorFont(*font\id)
			Draw_Text(*te, x, y, RSet(Str(*textline\lineNr), Int(Log10(ListSize(*te\textLine())) + 1)), color)
		EndIf
		
		If GetFlag(*te, #TE_EnableFolding)
			If *textline\foldState > 0
				Draw_FoldIcon(*te, xFoldLine, y + height / 2, foldiconSize, height, *textline\foldState)
				If *textline\foldSum > 0
					Draw_Line(xFoldLine, y - 1, 0, (height - FoldiconSize) / 2 + 1, *te\colors\foldIconBorder)
				EndIf
				If (*textline\foldSum > 0) And ( (*textline\foldSum + *textline\foldCount) > 0)
					Draw_Line(xFoldLine, y + (height + FoldiconSize) / 2, 0, (height - FoldiconSize) / 2, *te\colors\foldIconBorder)
				EndIf
			ElseIf (*textline\foldState < 0) And (*textline\foldSum > 0)
				If (*textline\foldSum + *textline\foldCount) > 0
					Draw_Line(xFoldLine, y - 1, 0, height + 1, *te\colors\foldIconBorder)
				Else
					Draw_Line(xFoldLine, y - 1, 0, height / 2 + 1, *te\colors\foldIconBorder)
				EndIf
				Draw_Line(xFoldLine, y + height / 2, FoldiconSize * 0.5, 0, *te\colors\foldIconBorder)
			ElseIf *textline\foldSum > 0
				Draw_Line(xFoldLine, y - 1, 0, height + 1, *te\colors\foldIconBorder)
			EndIf
		EndIf
	EndProcedure
	
	Procedure Draw_ScrollBar(x.d, y.d, width.d, height.d, rowHeight.d, index, maxIndex)
		Draw_Box(x, y, width, height, #TE_Ignore, RGBA(215,215,215,255))
		Draw_Line(x, y, 1, height, RGBA(235,235,235,255), 1)
		
		Protected scale.d
		
		If (maxIndex * rowHeight)
			scale = height / (maxIndex * rowHeight)
		Else
			scale = 0
		EndIf
		
		Draw_Box(x + 1.5, y + index * rowHeight * scale, width - 3, height * scale, #TE_Ignore, RGBA(160,160,160,255))
	EndProcedure
	
	Procedure Draw_AutoComplete(*te.TE_STRUCT)
		ProcedureReturnIf(*te = #Null Or ListSize(*te\autoComplete\entry()) = 0)
		
		With *te\autoComplete
			Protected index
			Protected y.d = \y
			Protected color1, color2, colorB
			
			SaveVectorState()
			
			VectorFont(*te\font(#TE_Font_Normal)\id)
			AddPathBox(\x, y, \width, \height)
			VectorSourceColor(RGBA(255,255,255, 255))
			FillPath()
			
			If SelectElement(\entry(), Clamp(-*te\autoComplete\scrollLine, 0, ListSize(*te\autoComplete\entry()) - 1))
				Repeat
					If ListIndex(\entry()) = \index
						Draw_Box(\x + 1, y + 1, \width - 2, *te\lineHeight - 2, #TE_Ignore, RGBA(0,108,215,255))
						color1 = RGBA(255,255,255,255)
						color2 = color1;RGBA(180,180,255,255)
						colorB = #TE_Ignore
					Else
						color1 = RGBA(0,0,0,255)
						color2 = color1;RGBA(100,100,100,255)
						colorB = RGBA(225,225,255,255)
					EndIf
					
					Protected txtIndex = FindString(\entry()\name, \text, 1, #PB_String_NoCase)
					Protected txtPos = \x + 5
					
					txtPos + Draw_Text(*te, txtPos, y, Left(\entry()\name, txtIndex - 1), color2, #TE_Ignore, 0, 1)
					txtPos + Draw_Text(*te, txtPos, y, Mid(\entry()\name, txtIndex, Len(\text)), color1, colorB, 0, 1)
					txtPos + Draw_Text(*te, txtPos, y, Mid(\entry()\name, txtIndex + Len(\text)), color2)
					
					y + *te\lineHeight
					index + 1
				Until (index >= *te\autoComplete\rows) Or NextElement(*te\autoComplete\entry()) = #Null
			EndIf
			
			If \isScrollBarVisible
				Draw_ScrollBar(\x + \width - \scrollBarWidth, \y + 1, \scrollBarWidth, \height - 1, *te\lineHeight, -\scrollLine, ListSize(\entry()))
			EndIf
			
			AddPathBox(\x, \y, \width, \height)
			VectorSourceColor(RGBA(215,215,215,255))
			StrokePath(1)
			
			RestoreVectorState()
		EndWith
	EndProcedure
	
	Procedure Draw_Selection(*te.TE_STRUCT, *view.TE_VIEW, *textLine.TE_TEXTLINE, lineNr, x.d, y.d, *cursor.TE_CURSOR, Array selection.a(1))
		ProcedureReturnIf((*te = #Null) Or (*view = #Null) Or (*textLine = #Null), y)
		
		Protected *t.Character
		Protected *font.TE_FONT
		Protected charNr
		Protected selected
		Protected width.d, tabWidth.d
		Protected height.d = *te\lineHeight - 1
		Protected maxHeight.d = DesktopUnscaledY(VectorOutputHeight() * *view\zoom)
		Protected maxWidth.d = DesktopUnscaledX(VectorOutputWidth() * *view\zoom)
		Protected wordWrapSize = Max(*te\wordWrapSize, 1)
		Protected xStart.d = x
		Protected selection.TE_RANGE
		Protected selectedTextColor = *te\colors\selectedText
		Protected selectionX = 0
		
		*font = @*te\font(#TE_Font_Normal)
		charNr = 1
		
		If *te\useRealTab
			tabWidth = Max(1, *font\width(#TAB) * *te\tabSize)
		Else
			tabWidth = Max(1, *font\width(' ') * *te\tabSize)
		EndIf
		
		If *textLine\text
			*t = @*textLine\text
		Else
			*t = @""
		EndIf
		
		If *cursor
			Selection_Get(*cursor, selection)
			If lineNr > selection\pos1\lineNr And lineNr < selection\pos2\lineNr
				selection(1) | %001
			EndIf
		EndIf
		
		Repeat
			
			If *te\cursorState\dragDropMode And (lineNr = *te\cursorState\dragPosition\lineNr) And (charNr = *te\cursorState\dragPosition\charNr)
				selection(charNr) | %010
			EndIf
			
			selected = 0
			Protected testSelection = #True
			
			While *cursor And testSelection
				testSelection = #False
				
				If lineNr = *cursor\position\lineNr And charNr = *cursor\position\charNr
					selection(charNr) | %010
					If *cursor = *te\maincursor
						selection(charNr) | %100
					EndIf
				EndIf
				
				If selected = #False
					If (lineNr < selection\pos1\lineNr) Or (lineNr > selection\pos2\lineNr)
						; line is above or under selection
					ElseIf (lineNr = selection\pos1\lineNr) And (charNr < selection\pos1\charNr)
						; char is before selection
					ElseIf (lineNr = selection\pos2\lineNr) And (charNr >= selection\pos2\charNr)
						; char is behind selection
						If NextElement(*te\cursor()) And (*te\cursor()\position\lineNr = lineNr Or *te\cursor()\selection\lineNr = lineNr)
							*cursor = *te\cursor()
							Selection_Get(*cursor, selection)
							testSelection = #True
						Else
							PreviousElement(*te\cursor())
							*cursor = #Null
						EndIf
					Else
						selected = #True
					EndIf
				EndIf
			Wend
			
			If selected
				selection(charNr) | %001
				If selectionX = 0
					selectionX = x
				EndIf
			Else
				If selectionX
; 					Draw_RoundBox(selectionX, y, x - selectionX + 1, height, height * 0.25, 0, #TE_Ignore, *te\colors\selectionBackground, 0)
					Draw_RoundBox(selectionX, y, x - selectionX + 1, height, height * 0.25, 0, #TE_Ignore, *te\colors\selectionBackground, 0)
					selectionX = 0
				EndIf
			EndIf
			
			If *t\c = #TAB
				width = tabWidth - Mod( (x - xStart) + tabWidth, tabWidth)
			Else
				width = *font\width(*t\c)
			EndIf
			
			charNr + 1
			x + width
			
			If *t\c = 0
				Break
			EndIf
			*t + #TE_CharSize
			
			If GetFlag(*te, #TE_EnableWordWrap)
				If (*te\wordWrapMode = #TE_WordWrap_Chars) And ((charNr - 1) % wordWrapSize = 0)
					x = xStart
					y + height
				ElseIf (*te\wordWrapMode = #TE_WordWrap_Size) And (x >= wordWrapSize)
					x = xStart
					y + height
				ElseIf (*te\wordWrapMode = #TE_WordWrap_Border) And (x >= maxWidth - width)
					x = xStart
					y + height
				EndIf
			EndIf
		Until (x > maxWidth) Or (y > maxHeight)
		
		If selectionX
			Draw_RoundBox(selectionX, y, x - selectionX + 1, height, height * 0.25, 0, #TE_Ignore, *te\colors\selectionBackground, 0)
		EndIf
	EndProcedure
	
	Procedure.d Draw_Textline(*te.TE_STRUCT, *view.TE_VIEW, *textLine.TE_TEXTLINE, lineNr, x.d, y.d, backgroundColor, Array selection.a(1))
		ProcedureReturnIf((*te = #Null) Or (*view = #Null) Or (*textLine = #Null), y)
		
		Protected *t.Character
		Protected *font.TE_FONT, fontNr
		Protected charNr
		Protected selected
		Protected style, highlightStyle, styleFcolor, styleBcolor, fColor, bColor, uColor
		Protected width.d, tabWidth.d
		Protected height.d = *te\lineHeight - 1
		Protected maxHeight.d = DesktopUnscaledY(VectorOutputHeight() * *view\zoom)
		Protected maxWidth.d = DesktopUnscaledX(VectorOutputWidth() * *view\zoom)
		Protected wordWrapSize = Max(*te\wordWrapSize, 1)
		Protected xStart.d = x
		Protected findIndentation = #True, indentationPos, previousIndentationPos
		Protected repeatedSelectionLen, repeatedSelectionPos
		Protected drawCursor
		Protected selectedTextColor = *te\colors\selectedText
		Protected selectionX = 0
		
		*font = @*te\font(#TE_Font_Normal)
		charNr = 1
		styleFColor = *te\textStyle(0)\fColor
		styleBcolor = #TE_Ignore
		fColor = styleFcolor
		bColor = styleBcolor
		
		If *te\useRealTab
			tabWidth = Max(1, *font\width(#TAB) * *te\tabSize)
		Else
			tabWidth = Max(1, *font\width(' ') * *te\tabSize)
		EndIf
		
		If IsFont(*font\nr)
			VectorFont(*font\id)
		EndIf
		
		If *textLine\text
			*t = @*textLine\text
		Else
			*t = @""
		EndIf
		
		If GetFlag(*te, #TE_EnableHorizontalFoldLines)
			If *textLine\foldCount > 0
				Draw_Line(*te\leftBorderOffset, y + 1, maxWidth, 0, *te\colors\horizontalFoldLines)
			EndIf
			If (*textLine\foldState = #TE_Folding_Folded) Or ((*textLine\foldCount < 0) And (*textLine\foldSum > 0))
				Draw_Line(*te\leftBorderOffset, y + height - 1, maxWidth, 0, *te\colors\horizontalFoldLines)
			EndIf
		EndIf
		
		Repeat
			If repeatedSelectionLen
				style = 0
			ElseIf charNr < ArraySize(*textLine\style())
				style = *textLine\style(charNr)
			EndIf
			
			If GetFlag(*te, #TE_EnableRepeatedSelection) And *te\repeatedSelection\textLen And IsRegularExpression(*te\regExRepeatedSelection); And (*te\cursorState\dragDropMode = 0)
				If repeatedSelectionLen
					repeatedSelectionLen - 1
					If repeatedSelectionLen = 0
						bColor = 0
						styleBcolor = 0
						highlightStyle = Style_FromCharNr(*textLine, charNr)
					EndIf
				EndIf
				If repeatedSelectionLen = 0
					; 					If MatchRegularExpression(*te\regExRepeatedSelection, Mid(*textLine\text, charNr, *te\repeatedSelection\textLen))
					; 						repeatedSelectionLen = *te\repeatedSelection\textLen
					; 						highlightStyle = #TE_Style_RepeatedSelection
					; 					EndIf
					If charNr >= repeatedSelectionPos And ExamineRegularExpression(*te\regExRepeatedSelection, Mid(*textLine\text, repeatedSelectionPos + 1))
						If NextRegularExpressionMatch(*te\regExRepeatedSelection)
							If RegularExpressionMatchPosition(*te\regExRepeatedSelection) = charNr - repeatedSelectionPos
								repeatedSelectionPos = charNr + RegularExpressionMatchLength(*te\regExRepeatedSelection)
								repeatedSelectionLen = *te\repeatedSelection\textLen
								highlightStyle = #TE_Style_RepeatedSelection
								; 								Break
							EndIf
						EndIf
					EndIf
					; 					If *te\repeatedSelection\mode & #TE_RepeatedSelection_WholeWord
					; 						If CompareMemoryString(*t, @*te\repeatedSelection\text, #PB_String_NoCase, *te\repeatedSelection\textLen) = #PB_String_Equal
					; 							repeatedSelectionLen = *te\repeatedSelection\textLen
					; 							highlightStyle = #TE_Style_RepeatedSelection
					; 						EndIf
					; 					EndIf
					
				EndIf
			ElseIf repeatedSelectionLen = 0 And GetFlag(*te, #TE_EnableSyntaxHighlight) And *te\highlightSyntax
				If charNr <= ArraySize(*textLine\syntaxHighlight())
					highlightStyle = *textLine\syntaxHighlight(charNr)
					If highlightStyle = #TE_Style_None
						highlightStyle = style
					EndIf
				EndIf
			EndIf
			
			If style Or highlightStyle
				styleBcolor = 0
				
				If highlightStyle And *te\textStyle(highlightStyle)\fColor <> #TE_Ignore
					fColor = *te\textStyle(highlightStyle)\fColor
				ElseIf style And *te\textStyle(style)\fColor <> #TE_Ignore
					fColor = *te\textStyle(style)\fColor
				EndIf
				
				If highlightStyle And *te\textStyle(highlightStyle)\bColor <> #TE_Ignore
					styleBcolor = *te\textStyle(highlightStyle)\bColor
				ElseIf style And *te\textStyle(style)\bColor <> #TE_Ignore
					styleBcolor = *te\textStyle(style)\bColor
				EndIf
				
				; 				If *te\textStyle(highlightStyle)\fontNr <> #TE_Ignore
				; 					fontNr = Clamp(*te\textStyle(highlightStyle)\fontNr, 0, ArraySize(*te\font()))
				If *te\textStyle(style)\fontNr <> #TE_Ignore	
					fontNr = Clamp(*te\textStyle(style)\fontNr, 0, ArraySize(*te\font()))
				Else
					fontNr = #TE_Font_Normal
				EndIf
				*font = @*te\font(fontNr)
				If IsFont(*font\nr)
					VectorFont(*font\id)
				EndIf
				
				If highlightStyle And *te\textStyle(highlightStyle)\uColor <> #TE_Ignore
					uColor = *te\textStyle(highlightStyle)\uColor
				ElseIf style And *te\textStyle(style)\uColor <> #TE_Ignore
					uColor = *te\textStyle(style)\fColor
				Else
					uColor = #TE_Ignore
				EndIf
				
				If uColor = #TE_Color_Text
					uColor = fColor
				EndIf
				
				highlightStyle = 0
				style = 0
			EndIf
			
			selected = selection(charNr) & 1
			
			If selection(charNr) & 2
				If *te\cursorState\dragDropMode = 0
					drawCursor = #TE_Cursor_Normal
				ElseIf (lineNr = *te\cursorState\dragPosition\lineNr) And (charNr = *te\cursorState\dragPosition\charNr)
					If selected
						drawCursor = #TE_Cursor_DragDropForbidden
					Else
						drawCursor = #TE_Cursor_DragDrop
					EndIf
				EndIf
			EndIf
			
			If selected
				bColor = *te\colors\selectionBackground
			Else
				bColor = styleBcolor
			EndIf
			
			If *t\c = #TAB
				width = tabWidth - Mod( (x - xStart) + tabWidth, tabWidth)
				If selected = 0
					Draw_Box(x, y, width + 1, height, #TE_Ignore, bColor)
				EndIf
			Else
				width = *font\width(*t\c)
				
				If selected = 0
					Draw_Box(x, y, width + 1, height, #TE_Ignore, bColor)
				EndIf
				
				If selected And (selectedTextColor <> #TE_Ignore)
					VectorSourceColor(selectedTextColor)
				Else
					VectorSourceColor(fColor)
				EndIf
				
				MovePathCursor(x, y)
				DrawVectorText(Chr(*t\c))
			EndIf
			
			If uColor <> #TE_Ignore
				Draw_Line(x, y + height - 1, width, 0, uColor)
			EndIf
			
			If GetFlag(*te, #TE_EnableShowWhiteSpace)
				If (*t\c = ' ') Or (*t\c = #TAB)
					If selected
						Draw_WhiteSpace(x, y, width, height, *t\c, backgroundColor)
					Else
						Draw_WhiteSpace(x, y, width, height, *t\c, *te\colors\indentationGuides)
					EndIf
				EndIf
			EndIf
			
			If GetFlag(*te, #TE_EnableIndentationLines) And findIndentation
				If *t\c > 32
					findIndentation = #False
				Else
					indentationPos = xStart + Int( (x - xStart) / tabWidth) * tabWidth
					If indentationPos <> previousIndentationPos
						previousIndentationPos = indentationPos
						Draw_DotLine(indentationPos + #TE_VectorDrawWidth * 3, y + 1, 0, height - 2, 1, height * 0.25, *te\colors\indentationGuides)
					EndIf
				EndIf
			EndIf
			
			If drawCursor
				If (*view <> *te\currentView) Or (*te\cursorState\blinkState Or *te\cursorState\dragDropMode > 0)
					Draw_Cursor(*te, x, y, width, height, drawCursor, selection(charNr) & %100)
				EndIf
				drawCursor = 0
			EndIf
			
			charNr + 1
			x + width
			
			If *t\c = 0
				Break
			EndIf
			*t + #TE_CharSize
			
			If GetFlag(*te, #TE_EnableWordWrap)
				If (*te\wordWrapMode = #TE_WordWrap_Chars) And ((charNr - 1) % wordWrapSize = 0)
					x = xStart
					y + height
				ElseIf (*te\wordWrapMode = #TE_WordWrap_Size) And (x >= wordWrapSize)
					x = xStart
					y + height
				ElseIf (*te\wordWrapMode = #TE_WordWrap_Border) And (x >= maxWidth - width)
					x = xStart
					y + height
				EndIf
			EndIf
		Until (x > maxWidth) Or (y > maxHeight)
		
		If *textLine\foldState = #TE_Folding_Folded
			Draw_Circle(x, y + height * 0.5, 0.5, *te\textStyle(#TE_Style_Comment)\fColor, *te\textStyle(#TE_Style_Comment)\fColor)
			x + height * 0.25
			Draw_Circle(x, y + height * 0.5, 0.5, *te\textStyle(#TE_Style_Comment)\fColor, *te\textStyle(#TE_Style_Comment)\fColor)
			x + height * 0.255
			Draw_Circle(x, y + height * 0.5, 0.5, *te\textStyle(#TE_Style_Comment)\fColor, *te\textStyle(#TE_Style_Comment)\fColor)
		EndIf
		
		ProcedureReturn y
	EndProcedure
	
	Procedure Draw_View(*te.TE_STRUCT, *view.TE_VIEW, redrawAll = #True)
		ProcedureReturnIf((*te = #Null) Or (*view = #Null))
		
		CompilerIf #TE_DEBUGDRAW
			DEBUGDRAWCOLOR = RGBA(Random(255),Random(255),Random(255),255)
			DEBUGDRAWCOUNTER + 1
		CompilerEndIf
		
		Protected backgroundColor
		Protected lineNr, lastLineNr
		Protected maxHeight.d, maxWidth.d
		Protected x.d, y.d, newY.d, dragTextX.d, dragTextY.d, cursorY = -1
		Protected height.d = *te\lineHeight - 1
		Protected selection.TE_RANGE
		Protected *cursor.TE_CURSOR = #Null
		Protected *textBlock.TE_TEXTBLOCK = #Null
		
		If IsGadget(*view\canvas) And StartVectorDrawing(CanvasVectorOutput(*view\canvas))
			If *view = *te\currentView
				backgroundColor = *te\colors\currentBackground
			Else
				backgroundColor = *te\colors\inactiveBackground
			EndIf
			
			If redrawAll
				VectorSourceColor(backgroundColor)
				FillVectorOutput()
			EndIf
			
			If *view\zoom
				ScaleCoordinates(1.0 / *view\zoom, 1.0 / *view\zoom)
			EndIf
			
			ScaleCoordinates(DesktopResolutionX(), DesktopResolutionY())
			TranslateCoordinates(#TE_VectorDrawAdjust, #TE_VectorDrawAdjust)
			
			If (*view\scroll\visibleLineNr >= 1) And (*view\scroll\visibleLineNr <= *te\visibleLineCount)
				maxHeight = DesktopUnscaledY(VectorOutputHeight() * *view\zoom)
				maxWidth = DesktopUnscaledX(VectorOutputWidth() * *view\zoom)
				
				x = *te\leftBorderOffset - *view\scroll\charX
				y = *te\topBorderSize
				
				PushListPosition(*te\cursor())
				PushListPosition(*te\textLine())
				
				If Textline_FromVisibleLineNr(*te, *view\scroll\visibleLineNr)
					lastLineNr = LineNr_from_VisibleLineNr(*te, *view\lastVisibleLineNr)
					*textBlock = FirstElement(*te\textBlock())
					
					
					*cursor = FirstElement(*te\cursor())
					Selection_Get(*cursor, selection)
					;ResetList(*te\cursor())
					
					Repeat
						newY = y
						lineNr = ListIndex(*te\textLine()) + 1
						
						Dim selection.a(Len(*te\textLine()\text) + 1)
						
						If *cursor And (*te\textLine()\lineNr > selection\pos2\lineNr)
							*cursor = #Null
						EndIf
						
						While (*cursor = #Null) And (lineNr >= selection\pos1\lineNr) And NextElement(*te\cursor())
							Selection_Get(*te\cursor(), selection)
							If (lineNr <= selection\pos2\lineNr)
								*cursor = *te\cursor()
							EndIf
						Wend
						
						If *te\textLine()\needRedraw Or redrawAll Or (*te\redrawRange\pos1\lineNr And lineNr >= *te\redrawRange\pos1\lineNr And lineNr <= *te\redrawRange\pos2\lineNr)
							Draw_Box(*te\leftBorderOffset - 1, y - 1, maxWidth, height + 2, #TE_Ignore, backgroundColor)
							
							If GetFlag(*te, #TE_EnableShowCurrentLine) And (GetFlag(*te, #TE_EnableAlwaysShowSelection) Or *te\isActive)  And *te\currentCursor And (lineNr = *te\currentCursor\position\lineNr) And (*te\cursorState\dragDropMode <= 0)
								cursorY = y
								If *view = *te\currentView
									Draw_Box(*te\leftBorderOffset - #TE_VectorDrawWidth * 0.5, y, maxWidth - *te\leftBorderOffset - #TE_VectorDrawWidth * 0.5, height , #TE_Ignore, *te\colors\currentLineBackground)
								Else
									Draw_Box(*te\leftBorderOffset - #TE_VectorDrawWidth * 0.5, y, maxWidth - *te\leftBorderOffset - #TE_VectorDrawWidth * 0.5, height, #TE_Ignore, *te\colors\inactiveLineBackground)
								EndIf
							ElseIf *te\textLine()\remark = #TE_Remark_Text
								Draw_Box(*te\leftBorderOffset - #TE_VectorDrawWidth * 0.5, y + 1, maxWidth - *te\leftBorderOffset - #TE_VectorDrawWidth * 0.5, height - 2, RGBA(255,255,255,255), RGBA(32,32,32,255))
							ElseIf *te\textLine()\remark = #TE_Remark_Error
								Draw_Box(*te\leftBorderOffset - #TE_VectorDrawWidth * 0.5, y + 1, maxWidth - *te\leftBorderOffset - #TE_VectorDrawWidth * 0.5, height - 2, RGBA(255,255,255,255), RGBA(100,0,0,255))
							ElseIf *te\textLine()\remark = #TE_Remark_Warning
								Draw_Box(*te\leftBorderOffset - #TE_VectorDrawWidth * 0.5, y + 1, maxWidth - *te\leftBorderOffset - #TE_VectorDrawWidth * 0.5, height - 2, RGBA(255,255,255,255), RGBA(0,0,100,255))
							EndIf
							
							Protected lastCursorIndex = ListIndex(*te\cursor())
							Draw_Selection(*te, *view, *te\textLine(), lineNr, x, y, *cursor, selection())
							newY = Draw_Textline(*te, *view, *te\textLine(), lineNr, x, y, backgroundColor, selection())
							
							If (ListIndex(*te\cursor()) > lastCursorIndex)
								*cursor = *te\cursor()
								Selection_Get(*cursor, selection)
							EndIf
							
							CompilerIf #TE_DEBUGDRAW
								Draw_Text(*te, maxWidth - 100, y, Str(*cursor), DEBUGDRAWCOLOR, RGBA(0,0,0,255))
							CompilerEndIf
						EndIf
						
						If (*te\cursorState\dragDropMode > 0) And (*te\cursorState\dragPosition\lineNr = lineNr)
							dragTextX = *te\cursorState\mouseX
							dragTextY = y
						EndIf
						
						If *te\textLine()\remark = 0
							Draw_LeftBorder(*te, *te\textLine(), lineNr, *te\leftBorderSize, y, *cursor)
						EndIf
						
						
						While *textBlock And *textBlock\firstLineNr < lineNr
							*textBlock = NextElement(*te\textBlock())
						Wend
						
						If *textBlock And (lineNr >= *textBlock\firstLineNr) And (*textBlock\firstLine\foldState & #TE_Folding_Folded)
							If *textBlock\lastLine = #Null
								Break
							ElseIf *textBlock\lastLineNr > lineNr
								ChangeCurrentElement(*te\textLine(), *textBlock\lastLine)
							EndIf
						EndIf
						
						y = newY + *te\lineHeight
						
					Until (y > maxHeight) Or (lineNr > lastLineNr) Or (NextElement(*te\textLine()) = #Null)
					
					; 					If *te\isActive And (cursorY <> -1)
					; 						If *view = *te\currentView
					; 							Draw_Box(*te\leftBorderOffset - #TE_VectorDrawWidth, cursorY, maxWidth - *te\leftBorderOffset - #TE_VectorDrawWidth, height, *te\colors\currentLineBorder, #TE_Ignore)
					; 						Else
					; 							Draw_Box(*te\leftBorderOffset - #TE_VectorDrawWidth, cursorY, maxWidth - *te\leftBorderOffset - #TE_VectorDrawWidth, height, *te\colors\currentLineBorder, #TE_Ignore)
					; 						EndIf
					; 					EndIf
					
					If (*te\cursorState\dragDropMode > 0) And (*view = *te\currentView)
						Draw_DragText(*te, dragTextX, dragTextY)
					EndIf
				EndIf
				
				PopListPosition(*te\textLine())
				PopListPosition(*te\cursor())
			EndIf
			
			If *te\autoComplete\isVisible And (*view = *te\currentView) And (cursorY <> -1)
				Draw_AutoComplete(*te)
			EndIf
			
			StopVectorDrawing()
		EndIf
		
		Draw_View(*te, *view\child[0], redrawAll)
		Draw_View(*te, *view\child[1], redrawAll)
	EndProcedure
	
	Procedure Draw(*te.TE_STRUCT, *view.TE_VIEW, cursorBlinkState = -1, redrawMode = 0)
		ProcedureReturnIf((*te = #Null) Or (*view = #Null))
		
		If _PBEdit_Window_\redrawing : ProcedureReturn : EndIf
		_PBEdit_Window_\redrawing = #True
		
		Protected redrawAll = #False
		
		If *te\wordWrapMode <> #TE_WordWrap_None
			redrawAll = #True
		EndIf
		
		If redrawMode & #TE_Redraw_All
			redrawAll = #True
			; 		ElseIf (redrawMode = 0) And (*te\redrawMode & #TE_Redraw_All)
			; 			redrawAll = #True
			; 		ElseIf *te\cursorState\dragDropMode > 0
			; 			redrawAll = #True
		EndIf
		
		If cursorBlinkState = -1
			*te\cursorState\blinkState = 1
			*te\cursorState\blinkSuspend = 1
		EndIf
		
		Draw_View(*te, *view, redrawAll)
		
		ForEach *te\textLine()
			*te\textLine()\needRedraw = #False
		Next
		*te\redrawRange\pos1\lineNr = 0
		*te\redrawRange\pos2\lineNr = 0		
		*te\redrawMode = 0
		
		_PBEdit_Window_\redrawing = #False
	EndProcedure
	
	;-
	;- ----------- READ XML -----------
	;-
	
	Procedure Settings_ReadXml(*te.TE_STRUCT, node)
		Protected subNode, text.s, value.s
		Protected col, colR, colG, colB, colA
		
		subNode = ChildXMLNode(node)
		While subNode
			Select LCase(GetXMLNodeName(node))
					
				Case "settings"
					
					text = Trim(GetXMLAttribute(subNode, "name"))
					value = Trim(GetXMLAttribute(subNode, "value"))
					
					Select LCase(text)
						Case "enablescrollbarhorizontal": SetFlag(*te, #TE_EnableScrollBarHorizontal, Val(value))
						Case "enablescrollbarvertical" : SetFlag(*te, #TE_EnableScrollBarVertical, Val(value))
						Case "enablezooming" : SetFlag(*te, #TE_EnableZooming, Val(value))
						Case "enablestyling" : SetFlag(*te, #TE_EnableStyling, Val(value))
						Case "enablelinenumbers" : SetFlag(*te, #TE_EnableLineNumbers, Val(value))
						Case "enableshowcurrentline" : SetFlag(*te, #TE_EnableShowCurrentLine, Val(value))
						Case "enablecasecorrection" : SetFlag(*te, #TE_EnableCaseCorrection, Val(value))
						Case "enablefolding" : SetFlag(*te, #TE_EnableFolding, Val(value))
						Case "enableshowwhitespace" : SetFlag(*te, #TE_EnableShowWhiteSpace, Val(value))
						Case "enableindentationlines" : SetFlag(*te, #TE_EnableIndentationLines, Val(value))
						Case "enablehorizontalfoldlines" : SetFlag(*te, #TE_EnableHorizontalFoldLines, Val(value))
						Case "enableindentation" : SetFlag(*te, #TE_EnableIndentation, Val(value))
						Case "enableautocomplete" : SetFlag(*te, #TE_EnableAutoComplete, Val(value))
						Case "enableautoclosingbracket" : SetFlag(*te, #TE_EnableAutoClosingBracket, Val(value))
						Case "enableautoclosingkeyword" : SetFlag(*te, #TE_EnableAutoClosingKeyword, Val(value))
						Case "enabledictionary" : SetFlag(*te, #TE_EnableDictionary, Val(value))
						Case "enablesyntaxhighlight" : SetFlag(*te, #TE_EnableSyntaxHighlight, Val(value))
						Case "enablebeautify" : SetFlag(*te, #TE_EnableBeautify, Val(value))
						Case "enablemulticursor" : SetFlag(*te, #TE_EnableMultiCursor, Val(value))
						Case "enablesplitscreen" : SetFlag(*te, #TE_EnableSplitScreen, Val(value))
						Case "enablerepeatedselection" : SetFlag(*te, #TE_EnableRepeatedSelection, Val(value))
						Case "enableselectpastedtext" : SetFlag(*te, #TE_EnableSelectPastedText, Val(value))
						Case "enablewordwrap" : SetFlag(*te, #TE_EnableWordWrap, Val(value))
						Case "enablereadonly" : SetFlag(*te, #TE_EnableReadOnly, Val(value))
						Case "enablealwaysshowselection" : SetFlag(*te, #TE_EnableAlwaysShowSelection, Val(value))
						Case "userealtab" : *te\useRealTab = Val(value)
						Case "tabsize" : *te\tabSize = Val(value)
						Case "fontname" : *te\fontName = value
						Case "lineheight" : *te\lineHeight = Val(value)
						Case "wordwrapsize" : *te\wordWrapSize = Val(value)
						Case "scrollbarwidth" : *te\scrollbarWidth = Val(value)
						Case "topbordersize" : *te\topBorderSize = Val(value)
						Case "leftbordersize" : *te\leftBorderSize = Val(value)
						Case "newlinechar" : *te\newLineChar = Val(value)
							*te\newLineText = Chr(*te\newLineChar)
						Case "foldchar" : *te\foldChar = Val(value)
						Case "cursorblinkdelay" : *te\cursorState\blinkDelay = Val(value)
						Case "cursorclickspeed" : *te\cursorState\clickSpeed = Val(value)
						Case "autocompletemaxrows" : *te\autoComplete\maxRows = Val(value)
						Case "autocompletemincharactercount" : *te\autoComplete\minCharacterCount = Val(value)
						Case "autocompletemode"
							Select LCase(value)
								Case "findatbegin" : *te\autoComplete\mode = #TE_Autocomplete_FindAtBegind
								Case "findany" : *te\autoComplete\mode = #TE_Autocomplete_FindAny
							EndSelect
						Case "repeatedselectionmincharactercount" : *te\repeatedSelection\minCharacterCount = Val(value)
						Case "repeatedselectionmode"
							*te\repeatedSelection\mode = 0
							If FindString(LCase(value), "nocase") : *te\repeatedSelection\mode | #TE_RepeatedSelection_NoCase : EndIf
							If FindString(LCase(value), "wholeword") : *te\repeatedSelection\mode | #TE_RepeatedSelection_WholeWord : EndIf
						Case "indentationmode"
							Select LCase(value)
								Case "auto" : *te\indentationMode = #TE_Indentation_Auto
								Case "block" : *te\indentationMode = #TE_Indentation_Block
								Case "none" : *te\indentationMode = #TE_Indentation_None
							EndSelect
						Case "cursorcomparemode"
							Select LCase(value)
								Case "nocase" : *te\cursorState\compareMode = #PB_String_NoCase
								Case "casesensitive" : *te\cursorState\compareMode = #PB_String_CaseSensitive
							EndSelect
						Case "wordwrapmode"
							Select LCase(value)
								Case "none" : *te\wordWrapMode = #TE_WordWrap_None
								Case "chars" : *te\wordWrapMode = #TE_WordWrap_Chars
								Case "size" : *te\wordWrapMode = #TE_WordWrap_Size
								Case "border" : *te\wordWrapMode = #TE_WordWrap_Border
							EndSelect
					EndSelect
					
				Case "colors"
					
					text = Trim(GetXMLAttribute(subNode, "name"))
					value = Trim(GetXMLAttribute(subNode, "value"))
					If value = "" Or LCase(value) = "ignore"
						col = #TE_Ignore
					Else
						colR = Val(Trim(StringField(value, 1, ",")))
						colG = Val(Trim(StringField(value, 2, ",")))
						colB = Val(Trim(StringField(value, 3, ",")))
						If Trim(StringField(value, 4, ",")) = ""
							colA = 255
						Else
							colA = Val(Trim(StringField(value, 4, ",")))
						EndIf
						col = RGBA(colR, colG, colB, colA)
					EndIf
					
					Select LCase(text)
						Case "defaulttext" : *te\colors\defaultText = col
						Case "selectedtext" : *te\colors\selectedText = col
						Case "cursor" : *te\colors\cursor = col
						Case "inactivebackground" : *te\colors\inactiveBackground = col
						Case "currentbackground" : *te\colors\currentBackground = col
						Case "selectionbackground" : *te\colors\selectionBackground = col
						Case "currentline" : *te\colors\currentLine = col
						Case "currentlinebackground" : *te\colors\currentLineBackground = col
						Case "currentlineborder" : *te\colors\currentLineBorder = col
						Case "inactivelinebackground" : *te\colors\inactiveLineBackground = col
						Case "indentationguides" : *te\colors\indentationGuides = col
						Case "horizontalfoldlines" : *te\colors\horizontalFoldLines = col
						Case "linenr" : *te\colors\lineNr = col
						Case "currentlinenr" : *te\colors\currentLineNr = col
						Case "linenrbackground" : *te\colors\lineNrBackground = col
						Case "foldicon" : *te\colors\foldIcon = col
						Case "foldiconborder" : *te\colors\foldIconBorder = col
						Case "foldiconbackground" : *te\colors\foldIconBackground = col
					EndSelect
					
			EndSelect
			
			subNode = NextXMLNode(subNode)
		Wend
	EndProcedure
	
	Procedure Settings_OpenXml(*te.TE_STRUCT, fileName.s)
		ProcedureReturnIf((*te = #Null) Or (fileName = ""))
		
		Protected xml, mainNode, node
		Protected result = #False
		
		If fileName <> ""
			xml = LoadXML(#PB_Any, fileName)
			
			If IsXML(xml)
				mainNode = MainXMLNode(xml)
				If mainNode
					node = ChildXMLNode(mainNode)
					While node
						Settings_ReadXml(*te, node)
						node = NextXMLNode(node)
					Wend
					result = #True
				EndIf
			EndIf
		EndIf
		
		If result = #False
			MessageRequester(*te\language\errorTitle, ReplaceString(*te\language\errorNotFound, "%N1", fileName), #PB_MessageRequester_Error)
		Else
			*te\leftBorderOffset = BorderSize(*te)
			
			Style_SetFont(*te, *te\fontName, *te\lineHeight)
			Style_SetDefaultStyle(*te)
			
			*te\redrawMode = #TE_Redraw_All
		EndIf
		
		ProcedureReturn result
	EndProcedure
	
	Procedure Styling_ReadXml(*te.TE_STRUCT, node)
		ProcedureReturnIf((*te = #Null) Or (node = #Null))
		
		Protected subNode, text.s, key.s, style, caseCorrection, flags.s, flag, i
		Protected folding, indentBefore, indentAfter
		
		subNode = ChildXMLNode(node)
		While subNode
			Select LCase(GetXMLNodeName(node))
					
				Case "styling"
					
					text = GetXMLAttribute(subNode, "name")
					If text
						style = 0
						Select LCase(text)
							Case "none" : style = #TE_Style_None
							Case "keyword" : style = #TE_Style_Keyword
							Case "function" : style = #TE_Style_Function
							Case "structure" : style = #TE_Style_Structure
							Case "text" : style = #TE_Style_Text
							Case "string" : style = #TE_Style_String
							Case "quote" : style = #TE_Style_Quote
							Case "comment" : style = #TE_Style_Comment
							Case "number" : style = #TE_Style_Number
							Case "pointer" : style = #TE_Style_Pointer
							Case "constant" : style = #TE_Style_Constant
							Case "operator" : style = #TE_Style_Operator
							Case "backslash" : style = #TE_Style_Backslash
							Case "comma" : style = #TE_Style_Comma
							Case "bracket" : style = #TE_Style_Bracket
							Case "label" : style = #TE_Style_Label
							Case "repeatedselection" : style = #TE_Style_RepeatedSelection
							Case "codematch" : style = #TE_Style_CodeMatch
							Case "codemismatch" : style = #TE_Style_CodeMismatch
							Case "bracketmatch" : style = #TE_Style_BracketMatch
							Case "bracketmismatch" : style = #TE_Style_BracketMismatch
								;Default					: style = #TE_Style_None
								
						EndSelect
						
						Protected fontNr
						Protected fontName.s = Trim(GetXMLAttribute(subNode, "fontNr"))
						Protected fColorRGBA = #TE_Ignore
						Protected fColor.s = Trim(GetXMLAttribute(subNode, "foreColor"))
						Protected bColorRGBA = #TE_Ignore
						Protected bColor.s = Trim(GetXMLAttribute(subNode, "backColor"))
						Protected uColorRGBA = #TE_Ignore
						Protected uColor.s = Trim(GetXMLAttribute(subNode, "underlineColor"))
						
						Select LCase(fontName)
							Case "" : fontNr = #TE_Ignore
							Default : : fontNr = Val(fontName)
						EndSelect
						
						If fColor
							If CountString(fColor, ",") = 2
								fColorRGBA = RGBA(Val(StringField(fColor, 1, ",")), 
								                  Val(StringField(fColor, 2, ",")), 
								                  Val(StringField(fColor, 3, ",")), 
								                  255)
							ElseIf CountString(fColor, ",") > 2
								fColorRGBA = RGBA(Val(StringField(fColor, 1, ",")), 
								                  Val(StringField(fColor, 2, ",")), 
								                  Val(StringField(fColor, 3, ",")), 
								                  Val(StringField(fColor, 4, ",")))
							EndIf
						EndIf
						
						If bColor
							If CountString(bColor, ",") = 2
								bColorRGBA = RGBA(Val(StringField(bColor, 1, ",")), 
								                  Val(StringField(bColor, 2, ",")), 
								                  Val(StringField(bColor, 3, ",")), 
								                  255)
							ElseIf CountString(bColor, ",") > 2
								bColorRGBA = RGBA(Val(StringField(bColor, 1, ",")), 
								                  Val(StringField(bColor, 2, ",")), 
								                  Val(StringField(bColor, 3, ",")), 
								                  Val(StringField(bColor, 4, ",")))
							EndIf
						EndIf
						
						If uColor
							If uColor = "TextColor"
								uColorRGBA = #TE_Color_Text
							ElseIf CountString(uColor, ",") = 2
								uColorRGBA = RGBA(Val(StringField(uColor, 1, ",")), 
								                  Val(StringField(uColor, 2, ",")), 
								                  Val(StringField(uColor, 3, ",")), 
								                  255)
							ElseIf CountString(uColor, ",") > 2
								uColorRGBA = RGBA(Val(StringField(uColor, 1, ",")), 
								                  Val(StringField(uColor, 2, ",")), 
								                  Val(StringField(uColor, 3, ",")), 
								                  Val(StringField(uColor, 4, ",")))
							EndIf
						EndIf
						
						Style_Set(*te, style, fontNr, fColorRGBA, bColorRGBA, uColorRGBA)
					EndIf
					
				Case "keywords"

					text = GetXMLAttribute(subNode, "name")
					text = RemoveString(text, #CR$)
					text = RemoveString(text, #LF$)
					text = RemoveString(text, #TAB$)
					text = RemoveString(text, " ")
					If text
						flags = GetXMLAttribute(subNode, "style")
						
						If flags = ""
							style = #TE_Ignore
						Else
							style = 0
							For i = CountString(flags, ",") + 1 To 1 Step - 1
								Select LCase(StringField(flags, i, ","))
									Case "none" : style = #TE_Style_None
									Case "keyword" : style = #TE_Style_Keyword
									Case "function" : style = #TE_Style_Function
									Case "structure" : style = #TE_Style_Structure
									Case "text" : style = #TE_Style_Text
									Case "string" : style = #TE_Style_String
									Case "comment" : style = #TE_Style_Comment
									Case "number" : style = #TE_Style_Number
									Case "pointer" : style = #TE_Style_Pointer
									Case "constant" : style = #TE_Style_Constant
									Case "operator" : style = #TE_Style_Operator
									Case "backslash" : style = #TE_Style_Backslash
									Case "comma" : style = #TE_Style_Comma
									Case "bracket" : style = #TE_Style_Bracket
									Case "codematch" : style = #TE_Style_CodeMatch
									Case "codemismatch" : style = #TE_Style_CodeMismatch
									Case "bracketmatch" : style = #TE_Style_BracketMatch
									Case "bracketmismatch" : style = #TE_Style_BracketMismatch
								EndSelect
							Next
						EndIf
						
						folding = Val(GetXMLAttribute(subNode, "fold"))
						indentBefore = Val(StringField(GetXMLAttribute(subNode, "indent"), 1, ","))
						indentAfter = Val(StringField(GetXMLAttribute(subNode, "indent"), 2, ","))
						
						If GetXMLAttribute(subNode, "casecorrect") = ""
							caseCorrection = #True
						Else
							caseCorrection = #TE_Ignore
						EndIf
						
						For i = CountString(text, ",") + 1 To 1 Step -1
							key = StringField(text, i, ",")
							KeyWord_Add(*te, key, style, caseCorrection)
							If folding
								KeyWord_Folding(*te, key, folding)
							EndIf
							If indentBefore Or indentAfter
								KeyWord_Indentation(*te, key, indentBefore, indentAfter)
							EndIf
						Next
					EndIf
					
				Case "syntax"
					
					text = GetXMLAttribute(subNode, "name")
					If text
						flags = GetXMLAttribute(subNode, "flags")
						flag = 0
						If flags
							For i = CountString(flags, ",") + 1 To 1 Step - 1
								Select LCase(StringField(flags, i, ","))
									Case "compiler" : flag | #TE_Syntax_Compiler
									Case "container" : flag | #TE_Syntax_Container
									Case "procedure" : flag | #TE_Syntax_Procedure
									Case "macro" : flag | #TE_Syntax_Macro
									Case "return" : flag | #TE_Syntax_Return
									Case "loop" : flag | #TE_Syntax_Loop
									Case "break" : flag | #TE_Syntax_Break
									Case "continue" : flag | #TE_Syntax_Continue
								EndSelect
							Next
						EndIf
						
						Syntax_Add(*te, text, flag)
					EndIf
					
				Case "linecontinuation"
					
					text = GetXMLAttribute(subNode, "name")
					If text
						key = ""
						For i = CountString(text, " ") + 1 To 1 Step -1
							If key
								key + Chr(10)
							EndIf
							key + StringField(text, i, " ")
						Next
						KeyWord_LineContinuation(*te, key)
					EndIf
					
				Case "comments"
					
					text = GetXMLAttribute(subNode, "comment")
					If text
						*te\commentChar = text
					EndIf
					
					text = GetXMLAttribute(subNode, "uncomment")
					If text
						*te\uncommentChar = text
					EndIf
					
			EndSelect
			
			subNode = NextXMLNode(subNode)
		Wend
	EndProcedure
	
	Procedure Styling_OpenXml(*te.TE_STRUCT, fileName.s, clearKeywords = #True)
		ProcedureReturnIf((*te = #Null) Or (fileName = ""))
		
		Protected xml, mainNode, node
		Protected result = #False
		
		If fileName <> ""

			xml = LoadXML(#PB_Any, fileName)
			
			If IsXML(xml)	
				If clearKeywords
					ClearMap(*te\keyWord())
				EndIf
				
				mainNode = MainXMLNode(xml)
				If mainNode
					node = ChildXMLNode(mainNode)
					While node
						Styling_ReadXml(*te, node)
						node = NextXMLNode(node)
					Wend
					result = #True
				EndIf
				
				ForEach *te\textLine()
					Style_Textline(*te, *te\textLine(), #TE_Styling_All)
				Next
			EndIf
		EndIf
		
		If result = #False
			MessageRequester(*te\language\errorTitle, ReplaceString(*te\language\errorNotFound, "%N1", fileName), #PB_MessageRequester_Error)
		EndIf
		
		ProcedureReturn result
	EndProcedure
	
	
	;-
	;- ----------- EVENT HANDLING -----------
	;-
	
	Procedure Event_Keyboard(*te.TE_STRUCT, *view.TE_VIEW, event_type)
		ProcedureReturnIf((*te = #Null) Or (*view = #Null) Or (IsGadget(*te\currentView\canvas) = 0))
		
		Protected key, modifiers
		Protected styleFlags
		Protected nrLinesToPageStart
		Protected overwriteMode = *te\cursorState\overwrite
		Protected clearSelection = #True
		Protected autocompleteShow = #False
		Protected autocompleteKey = 0
		Protected updateScroll = #True
		Protected needredraw = #False
		Protected *cursor.TE_CURSOR
		Protected addLineHistory = #True
		Protected undoCount = ListSize(*te\undo\entry())
		Protected previousScrollLine = *view\scroll\visibleLineNr
		Protected selection.TE_RANGE, previousSelection.TE_RANGE
		
		Selection_Get(*te\currentCursor, previousSelection)
		
		If *te\cursorState\dragDropMode > 0
			; we are in drag/drop mode
			; escape key	- cancel
			; ctrl key		- copy / move
			
			key = GetGadgetAttribute(*view\canvas, #PB_Canvas_Key)
			modifiers = GetGadgetAttribute(*view\canvas, #PB_Canvas_Modifiers)
			If key = #PB_Shortcut_Escape
				*te\cursorState\dragDropMode = #TE_CursorState_DragCancel
				RepeatedSelection_Clear(*te)
				*te\redrawMode = #TE_Redraw_All
			Else
				*te\cursorState\modifiers = modifiers
				If modifiers & #PB_Canvas_Control
					*te\cursorState\dragDropMode = #TE_CursorState_DragCopy
				Else
					*te\cursorState\dragDropMode = #TE_CursorState_DragMove
				EndIf
				
				If (event_type = #PB_EventType_KeyDown) Or (event_type = #PB_EventType_KeyUp)
					*te\redrawMode = #TE_Redraw_All
				EndIf
			EndIf
			
			If *te\redrawMode
				PostEvent(#TE_Event_Redraw, *te\window, 0, #TE_EventType_RedrawAll, *te\view)
			EndIf
			
			ProcedureReturn
		EndIf
		
		If event_type = #PB_EventType_KeyUp
			Undo_Update(*te)
			If *te\undo\clearRedo And (ListSize(*te\undo\entry()) > *te\undo\index)
				Undo_Clear(*te\redo)
			EndIf
			
			*te\undo\start = 0
			*te\undo\clearRedo = #True
			
			ProcedureReturn #True
		EndIf
		
		*te\undo\index = Undo_Start(*te, *te\undo)
		*te\undo\start = 1
		*te\needScrollUpdate = #True
		
		PushListPosition(*te\cursor())
		ForEach *te\cursor()
			; save the current cursor position and selection
			CopyStructure(*te\cursor()\position, *te\cursor()\previousPosition, TE_POSITION)
			CopyStructure(*te\cursor()\selection, *te\cursor()\previousSelection, TE_POSITION)
		Next
		PopListPosition(*te\cursor())
		
		If event_type = #PB_EventType_Input
			
			key = GetGadgetAttribute(*view\canvas, #PB_Canvas_Input)
			autocompleteShow = #True
			
			Select key
					
				Case 127
					
					key = 0
					
				Case 32 To #TE_CharRange
					
					Select key
						Case 'a' To 'z', 'A' To 'Z', '_', '0' To '9', 128 To #TE_CharRange
							styleFlags = #TE_Styling_UnfoldIfNeeded
							; 							Case ' '
							; 								styleFlags = #TE_Styling_UnfoldIfNeeded
						Default
							If *te\currentCursor And Parser_InsideStructure(*te, *te\currentCursor\position\textline, *te\currentCursor\position\charNr - 1)
								styleFlags = #TE_Styling_UpdateFolding
							Else
 								styleFlags = #TE_Styling_CaseCorrection | #TE_Styling_UpdateFolding
							EndIf
							*te\needDictionaryUpdate = #True
					EndSelect
					
					If LastElement(*te\cursor())
						
						Repeat
							*cursor = *te\cursor()
							
							If Selection_Delete(*te, *cursor, *te\undo)
								overwriteMode = #False
							Else
								overwriteMode = *te\cursorState\overwrite
							EndIf
							
							Textline_AddChar(*te, *cursor, key, overwriteMode, styleFlags, *te\undo)
							
							Folding_UnfoldTextline(*te, *cursor\position\lineNr)
							
							If *cursor\position\textline
								*cursor\position\textline\needStyling = #True
							EndIf
							; Scroll_Update(*te, *view, *te\cursor(), *te\cursor()\previousPosition\lineNr, *te\cursor()\previousPosition\charNr)
							
							If GetFlag(*te, #TE_EnableAutoClosingBracket)
								; 								If Parser_TokenAtCharNr(*te, *cursor\position\textline, *cursor\position\charNr)
								; 									If *te\parser\token\type <> #TE_Token_Whitespace And *te\parser\token\type <> #TE_Token_EOL
								; 										key = -1
								; 									EndIf
								; 								EndIf
								
								Select key
									Case 34, 39
										Textline_AddChar(*te, *cursor, key, overwriteMode, styleFlags, *te\undo)
										Cursor_Move(*te, *cursor, 0, -1)
									Case '('
										Textline_AddChar(*te, *cursor, ')', overwriteMode, styleFlags, *te\undo)
										Cursor_Move(*te, *cursor, 0, -1)
									Case '['
										Textline_AddChar(*te, *cursor, ']', overwriteMode, styleFlags, *te\undo)
										Cursor_Move(*te, *cursor, 0, -1)
									Case '{'
										Textline_AddChar(*te, *cursor, '}', overwriteMode, styleFlags, *te\undo)
										Cursor_Move(*te, *cursor, 0, -1)
								EndSelect
							EndIf
							
						Until PreviousElement(*te\cursor()) = #Null
					EndIf
					
					
				Default
					
					key = 0
					
			EndSelect
			
			If *te\currentCursor And Parser_TokenAtCharNr(*te, *te\currentCursor\position\textline, *te\currentCursor\position\charNr - 1)
				If ((*te\parser\token\type = #TE_Token_Text) Or (*te\parser\token\type = #TE_Token_Unknown))
					autocompleteShow = #True
				Else
					autocompleteShow = #False
				EndIf
				
				If Style_FromCharNr(*te\currentCursor\position\textline, *te\currentCursor\position\charNr, #True) = #TE_Style_Comment
					autocompleteShow = #False
				EndIf
			EndIf
			
			*te\redrawMode | #TE_Redraw_ChangedLines
			
		ElseIf event_type = #PB_EventType_KeyDown
			
			key = GetGadgetAttribute(*view\canvas, #PB_Canvas_Key)
			modifiers = GetGadgetAttribute(*view\canvas, #PB_Canvas_Modifiers)
			autocompleteShow = #False
			
			If ListSize(*te\textLine()) = 0
				; this should not happen - but if there is no textline, add one
				If Textline_Add(*te)
					Cursor_Position(*te, *te\currentCursor, 1, 1)
					*view\scroll\visibleLineNr = 1
					*view\scroll\charX = 1
				EndIf
			EndIf
			
			If modifiers & #PB_Canvas_Shift
				If key = #PB_Shortcut_Insert
					key = #PB_Shortcut_V
					modifiers = #PB_Canvas_Control
				EndIf
			EndIf
			
			If (modifiers & #PB_Canvas_Shift) Or (modifiers & #PB_Canvas_Control)
				clearSelection = #False
			Else
				clearSelection = #True
			EndIf
			
			If key <> #PB_Shortcut_Tab
				*te\autoComplete\lastKeyword = ""
			EndIf
			
			Select key
					
				Case #PB_Shortcut_Escape
					
					Cursor_Clear(*te, *te\maincursor)
					Find_Close(*te)
					DragDrop_Cancel(*te)
					Autocomplete_Hide(*te.TE_STRUCT)
					clearSelection = #False
					needredraw = #True
					
				Case #PB_Shortcut_Insert
					
					*te\cursorState\overwrite = Bool(Not *te\cursorState\overwrite)
					*te\cursorState\blinkSuspend = 1 
					*te\cursorState\blinkState = 1
					*te\redrawMode = #TE_Redraw_All
					needredraw = #True
					
				Case #PB_Shortcut_F1
					
; 					If modifiers & #PB_Canvas_Control
; 						Textline_AddRemark(*te, *te\currentCursor\position\lineNr, #TE_Remark_Warning, "*This is a warning*", *te\undo)
; 					ElseIf modifiers & #PB_Canvas_Shift
; 						Textline_AddRemark(*te, *te\currentCursor\position\lineNr, #TE_Remark_Error, "*This is an error*", *te\undo)
; 					Else
; 						Textline_AddRemark(*te, *te\currentCursor\position\lineNr, #TE_Remark_Text, "*This is a text*", *te\undo)
; 					EndIf
; 						
; 					needredraw = #True
; 					clearSelection = #True
; 					
; 					Undo_Update(*te)
					
				Case #PB_Shortcut_F2
					
					If modifiers & #PB_Canvas_Control
						Marker_Add(*te, *te\currentCursor\position\textline, #TE_Marker_Bookmark)
					Else
						Marker_Jump(*te, #TE_Marker_Bookmark)
					EndIf
					needredraw = #True
					
				Case #PB_Shortcut_F3
					
					If modifiers & #PB_Canvas_Shift
						needredraw = Find_Start(*te, *te\currentCursor, *te\currentCursor\position\lineNr, *te\currentCursor\position\charNr, GetGadgetText(*te\find\cmb_search), "", #TE_Find_Previous)
					Else
						needredraw = Find_Start(*te, *te\currentCursor, *te\currentCursor\position\lineNr, *te\currentCursor\position\charNr, GetGadgetText(*te\find\cmb_search), "", #TE_Find_Next)
					EndIf
					
					clearSelection = #False
					
				Case #PB_Shortcut_F4
					
					If modifiers & #PB_Canvas_Control
						Folding_ToggleAll(*te)
					Else
						needredraw + Folding_Toggle(*te, *te\currentCursor\position\lineNr)
					EndIf
					
					clearSelection = #False
					updateScroll = #False
					
				Case #PB_Shortcut_F9
					
					Marker_Add(*te, *te\currentcursor\position\textline, #TE_Marker_Breakpoint)
					needredraw = #True
					
				Case #PB_Shortcut_A
					
					If modifiers & #PB_Canvas_Control
						If Selection_SelectAll(*te)
							updateScroll = #False
							*te\needScrollUpdate = #False
						EndIf
					Else
						key = 0
					EndIf
					
				Case #PB_Shortcut_B
					
					If modifiers & #PB_Canvas_Control
						ForEach *te\cursor()
							If modifiers & #PB_Canvas_Alt
								Selection_Beautify(*te, *te\cursor())
							ElseIf modifiers & #PB_Canvas_Shift
								Selection_Uncomment(*te, *te\cursor())
							Else
								Selection_Comment(*te, *te\cursor())
							EndIf
						Next
						
						clearSelection = #False
						modifiers = 0
					Else
						key = 0
					EndIf
					
				Case #PB_Shortcut_C
					
					If modifiers & #PB_Canvas_Control
						ClipBoard_Copy(*te)
					EndIf
					
					key = 0
					
				Case #PB_Shortcut_D
					
					If modifiers & #PB_Canvas_Control
						ForEach *te\cursor()
							needredraw + Selection_Clone(*te, *te\cursor())
						Next
					Else
						key = 0
					EndIf
					
				Case #PB_Shortcut_E
					
					If modifiers & #PB_Canvas_Control
						If modifiers & #PB_Canvas_Shift
							Selection_MoveComment(*te, -1)
						Else
							Selection_MoveComment(*te, 1)
						EndIf
						
						modifiers = 0
						needredraw = #True
					Else
						key = 0
					EndIf
					
					clearSelection = #False
					updateScroll = #False
					*te\needScrollUpdate = #False
					
				Case #PB_Shortcut_F
					
					If modifiers & #PB_Canvas_Control
						
						If *te\currentCursor\position\lineNr = *te\currentCursor\selection\lineNr
							Find_Show(*te, Text_Get(*te, *te\currentCursor\position\lineNr, *te\currentCursor\position\charNr, *te\currentCursor\selection\lineNr, *te\currentCursor\selection\charNr))
						Else
							Find_Show(*te, "")
						EndIf
						
						ProcedureReturn
					Else
 						key = 0
					EndIf
					
					clearSelection = #False
					
				Case #PB_Shortcut_G
					
					If modifiers & #PB_Canvas_Control
						Cursor_GotoLineNr(*te, *te\currentCursor)
					Else
						key = 0
					EndIf
					
				Case #PB_Shortcut_H
					
					If modifiers & #PB_Canvas_Control
						
						If *te\currentCursor\position\lineNr = *te\currentCursor\selection\lineNr
							Find_Show(*te, Text_Get(*te, *te\currentCursor\position\lineNr, *te\currentCursor\position\charNr, *te\currentCursor\selection\lineNr, *te\currentCursor\selection\charNr), #True)
						Else
							Find_Show(*te, "", #True)
						EndIf
						
						ProcedureReturn
					Else
 						key = 0
					EndIf
					
					clearSelection = #False
					
				Case #PB_Shortcut_I
					
					If modifiers & #PB_Canvas_Control
						ForEach *te\cursor()
							Indentation_Range(*te, *te\cursor()\position\lineNr, *te\cursor()\selection\lineNr, *te\cursor(), #TE_Indentation_Auto)
						Next
						updateScroll = #False
					Else
						key = 0
					EndIf
					
				Case #PB_Shortcut_L
					
					If modifiers = (#PB_Canvas_Control | #PB_Canvas_Shift)
						Selection_ChangeCase(*te, #TE_Text_LowerCase)
					ElseIf modifiers = (#PB_Canvas_Control | #PB_Canvas_Alt)
						Cursor_AddMultiFromText(*te, Text_Get(*te, *te\currentCursor\position\lineNr, *te\currentCursor\position\charNr, *te\currentCursor\selection\lineNr, *te\currentCursor\selection\charNr))
						updateScroll = #False
					ElseIf modifiers = #PB_Canvas_Control
						Cursor_LineHistoryGoto(*te)
						addLineHistory = #False
						*te\needScrollUpdate = #True
					Else
						key = 0
					EndIf
					
				Case #PB_Shortcut_M
					
					If modifiers = #PB_Canvas_Control
						needredraw = Selection_SelectTextBlock(*te, *te\currentCursor\position\lineNr)
						clearSelection = #False
					Else
						key = 0
					EndIf
					
					
				Case #PB_Shortcut_U
					
					If modifiers = (#PB_Canvas_Control | #PB_Canvas_Shift)
						Selection_ChangeCase(*te, #TE_Text_UpperCase)
					Else
						key = 0
					EndIf
					
				Case #PB_Shortcut_V
					
					If modifiers & #PB_Canvas_Control
						ClipBoard_Paste(*te)
					Else
						key = 0
					EndIf
					
				Case #PB_Shortcut_X
					
					If modifiers & #PB_Canvas_Control
						ClipBoard_Cut(*te)
					Else
						key = 0
					EndIf
					
				Case #PB_Shortcut_Y
					
					If modifiers & #PB_Canvas_Control
						Undo_Update(*te)
						If Undo_Do(*te, *te\redo, *te\undo)
							*te\undo\clearRedo = #False
						EndIf
					Else
						key = 0
					EndIf
					
				Case #PB_Shortcut_Z
					
					If modifiers & #PB_Canvas_Control
						Undo_Update(*te)
						Undo_Do(*te, *te\undo, *te\redo)
					Else
						key = 0
					EndIf
					
				Case #PB_Shortcut_Tab
					
					If GetFlag(*te, #TE_EnableAutoClosingKeyword) And *te\autoComplete\lastKeyword
						ForEach *te\cursor()
							Autocomplete_InsertClosingKeyword(*te, *te\cursor(), *te\autoComplete\lastKeyword)
						Next
						*te\autoComplete\lastKeyword = ""
					ElseIf *te\autocomplete\isVisible
						autocompleteKey = #PB_Shortcut_Tab
					ElseIf modifiers & #PB_Canvas_Control
						Protected found, direction
						
						If modifiers & #PB_Canvas_Shift
							direction = -1
						Else
							direction = 1
						EndIf
						
						If View_Next(*te, *te\view, direction, @found) <> 1
							found = -1
							View_Next(*te, *te\view, direction, @found)
						EndIf
						
						needredraw = #True
						updateScroll = #False
						*te\needScrollUpdate = #False
					Else
						ForEach *te\cursor()
							If modifiers & #PB_Canvas_Shift
								If Selection_Unindent(*te, *te\cursor())
									*te\cursor()\previousPosition\charNr = *te\cursor()\position\charNr
									updateScroll = #False
									clearSelection = #False
								EndIf
							Else
								If Selection_Indent(*te, *te\cursor())
									*te\cursor()\previousPosition\charNr = *te\cursor()\position\charNr
									updateScroll = #False
									clearSelection = #False
								Else
									Selection_Delete(*te, *te\cursor(), *te\undo)
									Indentation_Add(*te, *te\cursor())
									clearSelection = #True
								EndIf
							EndIf
						Next
						
						If modifiers & #PB_Canvas_Shift
							modifiers = 0
						EndIf
					EndIf
					
				Case #PB_Shortcut_Back
					
					If LastElement(*te\cursor())
						Repeat
							
							If modifiers & #PB_Canvas_Control
								
								If modifiers & #PB_Canvas_Shift
									Cursor_Position(*te, *te\cursor(), *te\cursor()\position\lineNr, 1, #True, #True)
								Else
									Cursor_NextWord(*te, *te\cursor(), -1)
								EndIf
								
								Selection_SetRange(*te, *te\cursor(), *te\currentCursor\previousPosition\lineNr, *te\currentCursor\previousPosition\charNr, #False)
								If Selection_Delete(*te, *te\cursor(), *te\undo)
									*te\cursor()\previousPosition\lineNr = -1
								EndIf
								
								modifiers = 0
								
							Else
								
								Folding_UnfoldTextline(*te, *te\cursor()\position\lineNr)
								
								If Selection_Delete(*te, *te\cursor(), *te\undo) = #False
									If Textline_JoinPreviousLine(*te, *te\cursor(), *te\cursor()\position\textline, *te\undo) = #False
										Protected nextChar1 = Textline_CharAtPos(*te\cursor()\position\textline, *te\cursor()\position\charNr - 1)
										Protected nextChar2 = Textline_CharAtPos(*te\cursor()\position\textline, *te\cursor()\position\charNr)
										If GetFlag(*te, #TE_EnableAutoClosingBracket) And (nextChar1 = '(' And nextChar2 = ')') Or (nextChar1 = '[' And nextChar2 = ']') Or (nextChar1 = '{' And nextChar2 = '}')
											Cursor_Move(*te, *te\cursor(), 0, -1, *te\undo)
											Selection_SetRange(*te, *te\cursor(), *te\cursor()\position\lineNr, *te\cursor()\position\charNr + 2, #False)
										Else
											Selection_SetRange(*te, *te\cursor(), *te\cursor()\position\lineNr, *te\cursor()\position\charNr - 1, #False)
										EndIf
										
 										Selection_Delete(*te, *te\cursor(), *te\undo)
									EndIf
								EndIf
								
							EndIf
							
						Until PreviousElement(*te\cursor()) = #Null
					EndIf
					
					needredraw = #True
					
					If ListSize(*te\cursor()) = 1
						autocompleteShow = #True
					EndIf
					
				Case #PB_Shortcut_Delete
					
					If LastElement(*te\cursor())
						Repeat
							Folding_UnfoldTextline(*te, *te\cursor()\position\lineNr)
							
							If modifiers & #PB_Canvas_Control
								If Parser_TokenAtCharNr(*te, *te\cursor()\position\textline, *te\cursor()\position\charNr)
									Selection_SetRange(*te, *te\cursor(), *te\cursor()\position\lineNr, *te\cursor()\position\charNr + (*te\parser\token\charNr + *te\parser\token\size - *te\cursor()\position\charNr), #False)
								EndIf
							EndIf
							
							If Selection_Delete(*te, *te\cursor(), *te\undo) = #False
								If Textline_JoinNextLine(*te, *te\cursor(), *te\undo) = #False
									Selection_SetRange(*te, *te\cursor(), *te\cursor()\position\lineNr, Min(*te\cursor()\position\charNr + 1, Textline_Length(*te\cursor()\position\textline) + 1), #False)
									Selection_Delete(*te, *te\cursor(), *te\undo)
								EndIf
							EndIf
						Until (PreviousElement(*te\cursor()) = #Null)
					EndIf
					
				CompilerIf #PB_Compiler_OS = #PB_OS_Linux
				Case #PB_Shortcut_Return, #TE_Shortcut_PadReturn
				CompilerElse
				Case #PB_Shortcut_Return
				CompilerEndIf
					
					If LastElement(*te\cursor())
						Repeat
							Folding_UnfoldTextline(*te, *te\cursor()\position\lineNr, #False)
						Until PreviousElement(*te\cursor()) = #Null
					EndIf
					If *te\needFoldUpdate
						Folding_Update(*te, -1, -1)
					EndIf
					
					ForEach *te\cursor()
						Selection_Delete(*te, *te\cursor(), *te\undo)
						Protected *textline.TE_TEXTLINE = *te\cursor()\position\textline
						
						If Textline_AddText(*te, *te\cursor(), @*te\newLineText, Len(*te\newLineText), #TE_Styling_All, *te\undo)
							If (modifiers & #PB_Canvas_Control) = 0
								If *te\cursor()\position\textline <> *textline
									Textline_Beautify(*te, *textline)
								EndIf
								Textline_Beautify(*te, *te\cursor()\position\textline)
							EndIf
						EndIf
					Next
					ForEach *te\cursor()
						Protected indentation = Indentation_Range(*te, *te\cursor()\position\lineNr - 1, *te\cursor()\position\lineNr, #Null, *te\indentationMode)
						Cursor_Position(*te, *te\cursor(), *te\cursor()\position\lineNr, indentation)
					Next
					
					clearSelection = #True
					needredraw = #True
					
				Case #PB_Shortcut_Home
					
					If modifiers & #PB_Canvas_Control
						Selection_Start(*te\currentCursor, *te\currentCursor\position\lineNr, *te\currentCursor\position\charNr, modifiers & #PB_Canvas_Shift)
						Cursor_Position(*te, *te\currentCursor, 1, 1, #True, #True)
					Else
						ForEach *te\cursor()
							Selection_Start(*te\cursor(), *te\cursor()\position\lineNr, *te\cursor()\position\charNr, modifiers & #PB_Canvas_Shift)
							Cursor_Position(*te, *te\cursor(), *te\cursor()\position\lineNr, Textline_Start(*te\cursor()\position\textline, *te\cursor()\position\charNr), #True, #True)
						Next
					EndIf
					
				Case #PB_Shortcut_End
					
					If modifiers & #PB_Canvas_Control
						Selection_Start(*te\currentCursor, *te\currentCursor\position\lineNr, *te\currentCursor\position\charNr, modifiers & #PB_Canvas_Shift)
						Cursor_Position(*te, *te\currentCursor, ListSize(*te\textLine()) + 1, 1, #True, #True)
					Else
						ForEach *te\cursor()
							Selection_Start(*te\cursor(), *te\cursor()\position\lineNr, *te\cursor()\position\charNr, modifiers & #PB_Canvas_Shift)
							Cursor_Position(*te, *te\cursor(), *te\cursor()\position\lineNr, Textline_Length(*te\cursor()\position\textline) + 1, #True, #True)
						Next
					EndIf
					
				Case #PB_Shortcut_Left
					
					ForEach *te\cursor()
						If (modifiers & #PB_Canvas_Shift = 0) And Cursor_HasSelection(*te\cursor())
							needredraw + Cursor_SelectionStart(*te, *te\cursor())
							clearSelection = #True
						Else
							Selection_Start(*te\cursor(), *te\cursor()\position\lineNr, *te\cursor()\position\charNr, modifiers & #PB_Canvas_Shift)
							If modifiers & #PB_Canvas_Control
								Cursor_NextWord(*te, *te\cursor(), -1)
							ElseIf (modifiers & #PB_Canvas_Alt) = 0
								needredraw + Cursor_Move(*te, *te\cursor(), 0, -1)
								needredraw = 1
							EndIf
						EndIf
					Next
					
				Case #PB_Shortcut_Right
					
					ForEach *te\cursor()
						If (modifiers & #PB_Canvas_Shift = 0) And Cursor_HasSelection(*te\cursor())
							needredraw + Cursor_SelectionEnd(*te, *te\cursor())
							clearSelection = #True
						Else
							Selection_Start(*te\cursor(), *te\cursor()\position\lineNr, *te\cursor()\position\charNr, modifiers & #PB_Canvas_Shift)
							If modifiers & #PB_Canvas_Control
								Cursor_NextWord(*te, *te\cursor(), 1)
							ElseIf modifiers & #PB_Canvas_Alt = 0
								needredraw + Cursor_Move(*te, *te\cursor(), 0, 1)
								needredraw = 1
							EndIf
						EndIf
					Next
					
				Case #PB_Shortcut_Up
					
					If *te\autocomplete\isVisible
						autocompleteKey = #PB_Shortcut_Up
						key = 0
					Else
						If modifiers & #PB_Canvas_Control
							Selection_Start(*te\currentCursor, *te\currentCursor\position\lineNr, *te\currentCursor\position\charNr, modifiers & #PB_Canvas_Shift)
							If modifiers & #PB_Canvas_Alt
								If FirstElement(*te\cursor())
									*cursor = Cursor_Add(*te, *te\cursor()\position\lineNr - 1, Textline_CharNrFromScreenPos(*te, Textline_FromLine(*te, *te\cursor()\position\lineNr - 1), *te\maincursor\position\charX))
									If *cursor
										Scroll_Update(*te, *view, *cursor, -1, -1)
									EndIf
								EndIf
							ElseIf (modifiers & #PB_Canvas_Shift)
								Selection_Move(*te, -1)
							Else
								Scroll_Line(*te, *view, *te\currentCursor, *view\scroll\visibleLineNr - 1, #False)
							EndIf
						Else
							ForEach *te\cursor()
								Selection_Start(*te\cursor(), *te\cursor()\position\lineNr, *te\cursor()\position\charNr, modifiers & #PB_Canvas_Shift)
								needredraw + Cursor_Move(*te, *te\cursor(), -1, 0)
							Next
						EndIf
					EndIf
					
				Case #PB_Shortcut_Down
					
					If *te\autocomplete\isVisible
						autocompleteKey = #PB_Shortcut_Down
						key = 0
					Else
						If modifiers & #PB_Canvas_Control
							Selection_Start(*te\currentCursor, *te\currentCursor\position\lineNr, *te\currentCursor\position\charNr, modifiers & #PB_Canvas_Shift)
							If modifiers & #PB_Canvas_Alt
								If LastElement(*te\cursor())
									*cursor = Cursor_Add(*te, *te\cursor()\position\lineNr + 1, Textline_CharNrFromScreenPos(*te, Textline_FromLine(*te, *te\cursor()\position\lineNr + 1), *te\maincursor\position\charX))
									If *cursor
										Scroll_Update(*te, *view, *cursor, -1, -1)
									EndIf
								EndIf
							ElseIf modifiers & #PB_Canvas_Shift
								Selection_Move(*te, 1)
							Else
								Scroll_Line(*te, *view, *te\currentCursor, *view\scroll\visibleLineNr + 1, #False)
							EndIf
						Else
							ForEach *te\cursor()
								Selection_Start(*te\cursor(), *te\cursor()\position\lineNr, *te\cursor()\position\charNr, modifiers & #PB_Canvas_Shift)
								needredraw + Cursor_Move(*te, *te\cursor(), 1, 0, *te\undo)
							Next
						EndIf
					EndIf
					
				Case #PB_Shortcut_PageUp
					
					If *te\autocomplete\isVisible
						autocompleteKey = #PB_Shortcut_PageUp
						key = 0
					Else
						nrLinesToPageStart = *te\currentCursor\position\visibleLineNr - Textline_TopLine(*te)
						ForEach *te\cursor()
							Selection_Start(*te\cursor(), *te\cursor()\position\lineNr, *te\cursor()\position\charNr, modifiers & #PB_Canvas_Shift)
							Cursor_Move(*te, *te\cursor(), -*view\pageHeight, 0)
						Next
						Scroll_Line(*te, *view, *te\currentCursor, *te\currentCursor\position\visibleLineNr - nrLinesToPageStart)
					EndIf
					
				Case #PB_Shortcut_PageDown
					
					If *te\autocomplete\isVisible
						autocompleteKey = #PB_Shortcut_PageDown
						key = 0
					Else
						nrLinesToPageStart = *te\currentCursor\position\visibleLineNr - Textline_TopLine(*te)
						ForEach *te\cursor()
							Selection_Start(*te\cursor(), *te\cursor()\position\lineNr, *te\cursor()\position\charNr, modifiers & #PB_Canvas_Shift)
							Cursor_Move(*te, *te\cursor(), *view\pageHeight, 0)
						Next
						Scroll_Line(*te, *view, *te\currentCursor, *te\currentCursor\position\visibleLineNr - nrLinesToPageStart)
					EndIf
					
				Case #PB_Shortcut_Add
					
					If modifiers = #PB_Canvas_Control
						needredraw = View_Zoom(*te, *view, 1)
					EndIf
					
				Case #PB_Shortcut_Subtract
					
					If modifiers = #PB_Canvas_Control
						needredraw = View_Zoom(*te, *view, -1)
					EndIf
					
				Case #PB_Shortcut_Pad0
					
					If modifiers = #PB_Canvas_Control
						needredraw = View_Zoom(*te, *view, 0)
					EndIf
					
				Default
					
					key = 0
					
			EndSelect
			
			; 			If key
			; 				*te\redrawMode = #TE_Redraw_All
			; 			Else
			; 				*te\redrawMode = #TE_Redraw_ChangedLines
			; 			EndIf
			
		EndIf
		
		If key Or autocompleteKey
			
			If GetFlag(*te, #TE_EnableSelection) = 0
				Selection_ClearAll(*te)
			EndIf
			
			If *te\currentCursor And (*te\currentCursor\position\lineNr = *te\currentCursor\selection\lineNr)
				If Cursor_HasSelection(*te\currentCursor)
					RepeatedSelection_Update(*te, *te\currentCursor\position\lineNr, *te\currentCursor\position\charNr, *te\currentCursor\selection\lineNr, *te\currentCursor\selection\charNr)
				EndIf
			ElseIf *te\repeatedSelection
				RepeatedSelection_Clear(*te)
			EndIf
			
			If clearSelection
				;*te\redrawMode = #TE_Redraw_All
				; 				needredraw = #True
				Selection_ClearAll(*te)
			EndIf
			
			ForEach *te\cursor()
				If Position_Changed(*te\cursor()\previousPosition, *te\cursor()\position)
					Cursor_DeleteOverlapping(*te, *te\cursor(), #True)
				EndIf
			Next
			
			If *te\currentCursor
				If (*te\currentCursor\position\textline <> *te\currentCursor\previousPosition\textline)
					autocompleteShow = #False
				EndIf
			EndIf
			
			If GetFlag(*te, #TE_EnableAutoComplete) And autocompleteShow
				Autocomplete_Show(*te)
			EndIf
			
			If *te\autocomplete\isVisible
				If autocompleteKey = #PB_Shortcut_Up
					Autocomplete_Scroll(*te, -1)
				ElseIf autocompleteKey = #PB_Shortcut_Down
					Autocomplete_Scroll(*te, 1)
				ElseIf autocompleteKey = #PB_Shortcut_PageUp
					Autocomplete_Scroll(*te, -*te\autoComplete\rows)
				ElseIf autocompleteKey = #PB_Shortcut_PageDown
					Autocomplete_Scroll(*te, *te\autoComplete\rows)
				ElseIf autocompleteKey = #PB_Shortcut_Tab
					Autocomplete_Insert(*te)
				ElseIf autocompleteShow = #False
					Autocomplete_Hide(*te.TE_STRUCT)
				EndIf
				*te\redrawMode = #TE_Redraw_All
				needredraw = #True
			EndIf
			
			If *te\needFoldUpdate
				Folding_Update(*te, -1, -1)
			EndIf
			If *te\needDictionaryUpdate
				Autocomplete_UpdateDictonary(*te, 0, 0)
			EndIf
			
			If updateScroll Or *te\needScrollUpdate
				;  				Scroll_Update(*te, *te\currentView, *te\currentCursor, -1, -1, *te\needScrollUpdate)
				Scroll_UpdateAllViews(*te, *te\view, *te\currentView, *te\currentCursor)
			EndIf
			
			If Cursor_HasSelection(*te\currentCursor) = 0 And (ListSize(*te\cursor()) = 1)
				SyntaxHighlight_Start(*te, *te\currentCursor)
			ElseIf *te\highlightSyntax
				SyntaxHighlight_Clear(*te)
			EndIf
			
			If (modifiers & #PB_Canvas_Shift) And (*te\currentCursor\position\lineNr = *te\currentCursor\previousPosition\lineNr) And (*te\currentCursor\position\charNr <> *te\currentCursor\previousPosition\charNr)
				; 					*te\redrawMode | #TE_Redraw_All
			Else
				ForEach *te\cursor()
					If (*te\cursor()\previousSelection\lineNr <> *te\cursor()\selection\lineNr)
						; 							*te\redrawMode | #TE_Redraw_All
						Break
					EndIf
				Next
			EndIf
			
			Cursor_SignalChanges(*te, *te\currentCursor)
		EndIf
		
		If key And addLineHistory
			Cursor_LineHistoryAdd(*te)
		EndIf
		
		If *view\scroll\visibleLineNr <> previousScrollLine
			needredraw = #True
		Else
			ForEach *te\cursor()
				If Position_Changed(*te\cursor()\position, *te\cursor()\previousPosition)
					needredraw = #True
					Break
				ElseIf Position_Changed(*te\cursor()\selection, *te\cursor()\previousSelection)
					needredraw = #True
					Break
				EndIf
			Next
		EndIf
		
		Selection_Get(*te\currentCursor, selection)
		If Position_Changed(selection\pos1, previousSelection\pos1) Or Position_Changed(selection\pos2, previousSelection\pos2)
			If ListSize(*te\cursor()) > 1
				*te\redrawMode = #TE_Redraw_All
			EndIf
			
			needRedraw = #True
			*te\redrawRange\pos1\lineNr = Min(selection\pos1\lineNr, previousSelection\pos1\lineNr)
			*te\redrawRange\pos2\lineNr = Max(selection\pos2\lineNr, previousSelection\pos2\lineNr)
			*te\cursorState\blinkState = 1
		EndIf
		
		If needredraw Or *te\redrawMode
			If *te\redrawMode & #TE_Redraw_All
				PostEvent(#TE_Event_Redraw, 0, 0, #TE_EventType_RedrawAll, *te\view)
			Else
				PostEvent(#TE_Event_Redraw, 0, 0, #TE_EventType_RedrawChangedLines, *te\view)
			EndIf
		EndIf
		
		Find_SetSelectionCheckbox(*te)
		
	EndProcedure
	
	Procedure Event_Mouse_LeftButtonDown(*te.TE_STRUCT, *view.TE_VIEW, *cursor.TE_CURSOR)
		Protected *cursorState.TE_CURSORSTATE = *te\cursorState
		
		*cursorState\firstMousePosition = *cursorState\mousePosition
		
		If *cursorState\mousePosition = #TE_MousePosition_AutoComplete
			ProcedureReturn 1
		ElseIf *cursorState\mousePosition = #TE_MousePosition_AutoCompleteScrollBar
			*te\autoComplete\lastScrollPos = *te\autoComplete\scrollLine
			*te\autoComplete\scollMousePos = *cursorState\mouseY
			*te\autoComplete\scrollDistance = 0
			ProcedureReturn 1
		EndIf
		Autocomplete_Hide(*te.TE_STRUCT)
		
		If (*cursorState\time - *cursorState\firstClickTime) > *cursorState\clickSpeed
			*cursorState\clickCount = 0
		EndIf
		*cursorState\firstClickTime = *cursorState\time

		If Cursor_GetScreenPos(*te, *view, *cursorState\canvasMouseX, *cursorState\canvasMouseY, *cursorState\position) = #False
			ProcedureReturn 1
		EndIf
		
		If GetFlag(*te, #TE_EnableSelection) And Position_Equal(*cursorState\position, *cursorState\previousPosition)
			*cursorState\clickCount + 1
		Else
			*cursorState\clickCount = 1
		EndIf
		
		If *cursorState\clickCount = 1
			If (*cursorState\modifiers & #PB_Canvas_Shift) = 0
				
				If *cursorState\dragStart = #False
					If *cursorState\modifiers & #PB_Canvas_Control
						*cursor = Cursor_Add(*te, *cursorState\position\lineNr, *cursorState\position\charNr)
						If *cursor = #Null
							ProcedureReturn 1
						EndIf
						CopyStructure(*cursor\position, *cursorState\position, TE_POSITION)
					ElseIf (*cursorState\mousePosition <> #TE_MousePosition_FoldState) And (*cursorState\modifiers & #PB_Canvas_Alt = 0)
						Cursor_Clear(*te, *cursor)
					EndIf
				EndIf
				
				If *cursorState\mousePosition = #TE_MousePosition_TextArea
					If Position_InsideSelection(*te, *view, *cursorState\mouseX, *cursorState\mouseY)
						*cursorState\dragStart = #True
						CopyStructure(*cursorState\position, *cursorState\previousPosition, TE_POSITION)
						ProcedureReturn 1
					EndIf
				EndIf
				
				*cursorState\firstClickX = *cursorState\canvasMouseX
				*cursorState\firstClickY = *cursorState\canvasMouseY

				CopyStructure(*cursorState\position, *cursor\firstPosition, TE_POSITION)
			EndIf
		EndIf
		
		If *cursorState\mousePosition = #TE_MousePosition_LineNumber
			
			If GetFlag(*te, #TE_EnableSelection)
				If (*cursorState\modifiers & #PB_Canvas_Control) And (GetFlag(*te, #TE_EnableMultiCursor) = 0)
					Selection_SelectAll(*te)
				Else
					Undo_Start(*te, *te\undo)
					
					If *cursorState\modifiers & #PB_Canvas_Shift
						If *cursorState\position\lineNr <= *cursor\firstPosition\lineNr
							Cursor_Position(*te, *cursor, *cursorState\position\lineNr, 1, #False, #True, *te\undo)
							Selection_SetRange(*te, *cursor, *cursorState\firstSelection\pos1\lineNr, Textline_LastCharNr(*te, *cursorState\firstSelection\pos1\lineNr))
						Else
							Cursor_Position(*te, *cursor, *cursorState\position\lineNr + 1, 1, #False, #True, *te\undo)
							Selection_SetRange(*te, *cursor, *cursorState\firstSelection\pos1\lineNr, *cursorState\firstSelection\pos1\charNr)
						EndIf
					Else
						Cursor_Position(*te, *cursor, *cursorState\position\lineNr + 1, 1, #False, #True, *te\undo)
						
						Selection_SetRange(*te, *cursor, *cursorState\position\lineNr, 1)
						Selection_Get(*cursor, *cursorState\firstSelection)
						CopyStructure(*cursorState\position, *cursor\firstPosition, TE_POSITION)
					EndIf
				EndIf
				Undo_Update(*te)
			EndIf
			
		ElseIf *cursorState\mousePosition = #TE_MousePosition_FoldState
			
			If *cursorState\position\textline And (*cursorState\position\textline\foldState > 0)
				Protected scrollLineNr = *view\scroll\visibleLineNr
				Folding_Toggle(*te, *cursorState\position\lineNr)
				*cursorState\dragDropMode = -1
			EndIf
			
		ElseIf *cursorState\mousePosition = #TE_MousePosition_TextArea

			If *cursorState\clickCount = 1
				
				If (*cursorState\modifiers & #PB_Canvas_Shift = 0) And (*cursorState\modifiers & #PB_Canvas_Control = 0); And (*cursorState\state = 0)
					Selection_Start(*cursor, *cursorState\position\lineNr, *cursorState\position\charNr)
					; *te\redrawMode = #TE_Redraw_All
				EndIf
				
				Undo_Start(*te, *te\undo)
				Cursor_Position(*te, *cursor, *cursorState\position\lineNr, *cursorState\position\charNr, #True, #True, *te\undo)
				Undo_Update(*te)
				
				If GetFlag(*te, #TE_EnableSelection) = 0
					Selection_ClearAll(*te)
				EndIf
				
				CopyStructure(*cursor\position, *cursor\firstPosition, TE_POSITION)
				
				If (*cursorState\modifiers & #PB_Canvas_Shift) = 0
					Selection_Get(*cursor, *cursorState\firstSelection)
				EndIf
				
			ElseIf *cursorState\clickCount = 2
	
				If (*cursorState\position\lineNr = *cursorState\previousPosition\lineNr) And (*cursorState\position\charNr = *cursorState\previousPosition\charNr)
					; double-click:		select the word under the cursor
					
					If Selection_WholeWord(*te, *cursor, *cursorState\position\lineNr, *cursorState\position\charNr)
						CopyStructure(*cursor\position, *cursor\firstPosition, TE_POSITION)
						Selection_Get(*cursor, *cursorState\firstSelection)
					EndIf
					
				EndIf
				
			ElseIf *cursorState\clickCount = 3
				; tripple-click:	select whole line
				
				Selection_SetRange(*te, *cursor, *cursorState\position\lineNr, 1)
				Cursor_Position(*te, *cursor, *cursorState\position\lineNr + 1, 1)
				
				CopyStructure(*cursor\position, *cursor\firstPosition, TE_POSITION)
				Selection_Get(*cursor, *cursorState\firstSelection)
				
			ElseIf (*cursorState\clickCount = 4)
				; quadruple-click:		select all
				
				Selection_SelectAll(*te)
			EndIf
			
		EndIf
		
		If *te\needFoldUpdate
			Folding_Update(*te, -1, -1)
		EndIf
		
		Cursor_DeleteOverlapping(*te, *cursor)
		
		If ListSize(*te\cursor()) = 1 And Cursor_HasSelection(*te\currentCursor) = #False
			SyntaxHighlight_Start(*te, *te\currentCursor)
		Else
			*te\highlightSyntax = 0
		EndIf
		
		Cursor_LineHistoryAdd(*te)
		
		; 				RepeatedSelection_Clear(*te)
		; 				RepeatedSelection_Update(*te, *cursor\position\lineNr, *cursor\position\charNr, *cursor\selection\lineNr, *cursor\selection\charNr)
		
		
		CopyStructure(*cursorState\position, *cursorState\previousPosition, TE_POSITION)
		
		Find_SetSelectionCheckbox(*te)
		
		*cursorState\needRedraw = #True
	EndProcedure
	
	Procedure Event_Mouse_LeftButtonUp(*te.TE_STRUCT, *view.TE_VIEW, *cursor.TE_CURSOR)

		Protected *cursorState.TE_CURSORSTATE = *te\cursorState
		
		If (*te\autoComplete\isScrolling = #False) And *cursorState\mousePosition = #TE_MousePosition_AutoComplete
			*te\autoComplete\index = Clamp( (*cursorState\mouseY - *te\autoComplete\y - *te\topBorderSize) / *te\lineHeight - *te\autoComplete\scrollLine, 0, ListSize(*te\autoComplete\entry()) - 1)
			
			PostEvent(#TE_Event_Redraw, 0, 0, #TE_EventType_RedrawAll, *te\view)
			ProcedureReturn 1
		EndIf
		
		*te\redrawMode = #TE_Redraw_All
		*te\autoComplete\isScrolling = #False
		
		If (*cursorState\time - *cursorState\firstClickTime) > *cursorState\clickSpeed
			*cursorState\clickCount = 0
		EndIf
		
		If *cursorState\clickCount = 3
			*cursorState\clickCount = 0
		EndIf		
		If (*cursorState\dragDropMode = #TE_CursorState_Idle) Or (*cursorState\dragDropMode = #TE_CursorState_DragCancel)
			*cursorState\dragDropMode = 0
			*te\redrawMode = #TE_Redraw_All
		ElseIf (*cursorState\dragDropMode = #TE_CursorState_DragCopy) Or (*cursorState\dragDropMode = #TE_CursorState_DragMove)
			DragDrop_Drop(*te)
		ElseIf *cursorState\mousePosition = #TE_MousePosition_TextArea
			If *cursorState\clickCount = 1
				If Cursor_GetScreenPos(*te, *view, *cursorState\canvasMouseX, *cursorState\canvasMouseY, *cursorState\position)
					If Position_Equal(*cursorState\position, *cursorState\previousPosition)
						If (*cursorState\modifiers & #PB_Canvas_Shift) = 0 And (*cursorState\modifiers & #PB_Canvas_Control) = 0
							Selection_Clear(*te, *cursor)
						EndIf
						If (*cursorState\modifiers & #PB_Canvas_Control) = 0
							Cursor_Clear(*te, *cursor)
						EndIf
					
						Cursor_Position(*te, *cursor, *cursorState\previousPosition\lineNr, *cursorState\previousPosition\charNr)
					EndIf
				EndIf
			EndIf
		EndIf
		
		*view\scroll\autoScrollV = #False
		*view\scroll\autoScrollH = #False
		RemoveWindowTimer(*te\window, #TE_Timer_Scroll)
		
		If *te\currentCursor And RepeatedSelection_Update(*te, *te\currentCursor\position\lineNr, *te\currentCursor\position\charNr, *te\currentCursor\selection\lineNr, *te\currentCursor\selection\charNr) = #False
			RepeatedSelection_Clear(*te)
		EndIf
		
		Find_SetSelectionCheckbox(*te)
	EndProcedure
	
	Procedure Event_Mouse_Move(*te.TE_STRUCT, *view.TE_VIEW, *cursor.TE_CURSOR)
		Protected *cursorState.TE_CURSORSTATE = *te\cursorState
		
		If (*cursorState\buttons & #PB_Canvas_LeftButton And *cursorState\mousePosition = #TE_MousePosition_AutoCompleteScrollBar) Or *te\autoComplete\isScrolling 
			If *te\autoComplete\height
				*te\autoComplete\isScrolling = #True
				*te\autoComplete\scrollDistance = (*te\autoComplete\scollMousePos - *cursorState\mouseY)
				*te\autoComplete\scrollLine = *te\autoComplete\lastScrollPos + (*te\autoComplete\scrollDistance / DesktopScaledY(*te\autoComplete\height)) * ListSize(*te\autoComplete\entry())
				*te\autoComplete\scrollLine = Clamp(*te\autoComplete\scrollLine, -(ListSize(*te\autoComplete\entry()) - *te\autoComplete\maxRows), 0)
				PostEvent(#TE_Event_Redraw, 0, 0, #TE_EventType_RedrawAll, *te\view)
			EndIf
			ProcedureReturn 1
		EndIf
		
		If *cursorState\mousePosition = #TE_MousePosition_AutoComplete
			SetGadgetAttribute(*view\canvas, #PB_Canvas_Cursor, #PB_Cursor_Default)
			ProcedureReturn 1
		EndIf
		
		If *cursorState\dragStart And (*cursorState\clickCount = 1)
			DragDrop_Start(*te)
		EndIf
		
		If *cursorState\dragDropMode
			*te\redrawMode = #TE_Redraw_All
		EndIf
		
		*view\scroll\scrollDelay = 0
		If *cursorState\buttons & #PB_Canvas_LeftButton
			Protected yTop = DesktopScaledY(GadgetY(*view\canvas, #PB_Gadget_ScreenCoordinate)) + (*te\lineHeight * 0.5) * *view\zoom
			Protected yBottom = DesktopScaledY(GadgetY(*view\canvas, #PB_Gadget_ScreenCoordinate) + GadgetHeight(*view\canvas)) - (*te\lineHeight * 0.5) * *view\zoom
			Protected xLeft = DesktopScaledX(GadgetX(*view\canvas, #PB_Gadget_ScreenCoordinate) + *te\leftBorderOffset / *view\zoom)
			Protected xRight = DesktopScaledX(GadgetX(*view\canvas, #PB_Gadget_ScreenCoordinate) + GadgetWidth(*view\canvas)) - (*te\lineHeight * 0.5) * *view\zoom
			
			If (*cursorState\desktopMouseY < yTop) Or (*cursorState\desktopMouseY > yBottom)
				If *view\scroll\autoScrollV = #False
					*view\scroll\autoScrollV = #True
					RemoveWindowTimer(*te\window, #TE_Timer_Scroll)
					AddWindowTimer(*te\window, #TE_Timer_Scroll, 25)
				EndIf
				ProcedureReturn 1
			ElseIf *view\scroll\autoScrollV
				*view\scroll\autoScrollV = #False
				RemoveWindowTimer(*te\window, #TE_Timer_Scroll)
			EndIf
			
			If (*cursorState\desktopMouseX < xLeft) Or (*cursorState\desktopMouseX > xRight)
				If *view\scroll\autoScrollH = #False
					*view\scroll\autoScrollH = #True
					RemoveWindowTimer(*te\window, #TE_Timer_Scroll)
					AddWindowTimer(*te\window, #TE_Timer_Scroll, 25)
				EndIf
				; ProcedureReturn 1
			ElseIf *view\scroll\autoScrollH
				*view\scroll\autoScrollH = #False
				RemoveWindowTimer(*te\window, #TE_Timer_Scroll)
			EndIf
		EndIf
		
		If *cursorState\mousePosition = #TE_MousePosition_TextArea
			SetGadgetAttribute(*view\canvas, #PB_Canvas_Cursor, #PB_Cursor_IBeam)
		ElseIf *cursorState\mousePosition = #TE_MousePosition_LineNumber
			SetGadgetAttribute(*view\canvas, #PB_Canvas_Cursor, #PB_Cursor_Hand)
		Else
			SetGadgetAttribute(*view\canvas, #PB_Canvas_Cursor, #PB_Cursor_Default)
		EndIf
		
		If (*cursorState\buttons = #PB_Canvas_LeftButton) And GetFlag(*te, #TE_EnableSelection)
			
			If Cursor_GetScreenPos(*te, *view, *cursorState\canvasMouseX, *cursorState\canvasMouseY , *cursorState\position); And Position_Changed(*cursor\previousPosition, position)
				
				If *cursorState\dragDropMode
					CopyStructure(*cursorState\position, *cursorState\dragPosition, TE_POSITION)
				Else
					
					If Position_InsideRange(*cursorState\position, *cursorState\firstSelection, #False) And (*cursorState\clickCount > 1)
						Selection_SetRange(*te, *cursor, *cursorState\firstSelection\pos1\lineNr, *cursorState\firstSelection\pos1\charNr)
						Cursor_Position(*te, *cursor, *cursorState\firstSelection\pos2\lineNr, *cursorState\firstSelection\pos2\charNr)
					Else
						If (*cursorState\mousePosition = #TE_MousePosition_LineNumber) Or (Abs(*cursorState\firstSelection\pos1\lineNr - *cursorState\firstSelection\pos2\lineNr) = 1 And *cursorState\firstSelection\pos1\charNr = 1 And *cursorState\firstSelection\pos1\charNr = 1)
							If *cursorState\firstMousePosition = #TE_MousePosition_LineNumber
								If *cursorState\position\lineNr < *cursorState\firstSelection\pos1\lineNr
									Cursor_Position(*te, *cursor, *cursorState\position\lineNr, 1)
									Selection_SetRange(*te, *cursor, *cursorState\firstSelection\pos1\lineNr, Textline_LastCharNr(*te, *cursorState\firstSelection\pos1\lineNr))
								Else
									Cursor_Position(*te, *cursor, *cursorState\position\lineNr + 1, 1)
									Selection_SetRange(*te, *cursor, *cursorState\firstSelection\pos1\lineNr, 1)
								EndIf
							Else
								If *cursorState\position\lineNr <= *cursorState\firstSelection\pos1\lineNr
									Cursor_Position(*te, *cursor, *cursorState\position\lineNr, 1)
									Selection_SetRange(*te, *cursor, *cursorState\firstSelection\pos2\lineNr, *cursorState\firstSelection\pos2\charNr)
								Else
									Cursor_Position(*te, *cursor, *cursorState\position\lineNr, 1)
									Selection_SetRange(*te, *cursor, *cursorState\firstSelection\pos1\lineNr, *cursorState\firstSelection\pos1\charNr)
								EndIf
							EndIf
						Else
							CopyStructure(*cursorState\firstSelection, *cursorState\selection, TE_RANGE)
							Selection_Add(*cursorState\selection, *cursorState\position\lineNr, *cursorState\position\charNr)
							
							Cursor_Position(*te, *cursor, *cursorState\position\lineNr, *cursorState\position\charNr)
							
							If Position_InsideRange(*cursorState\position, *cursorState\selection, #False) < 0
								Selection_SetRange(*te, *cursor, *cursorState\selection\pos2\lineNr, *cursorState\selection\pos2\charNr)
							Else
								Selection_SetRange(*te, *cursor, *cursorState\selection\pos1\lineNr, *cursorState\selection\pos1\charNr)
							EndIf
							
							; 									If Position_Changed(*cursor\previousPosition, *cursor\position)
							; 										*te\redrawMode = #TE_Redraw_All
							; 									EndIf
							
						EndIf
					EndIf
					
					If *cursorState\modifiers & #PB_Canvas_Alt
						Selection_SetRectangle(*te, *cursor)
					Else
						Cursor_DeleteOverlapping(*te, *cursor)
					EndIf
					
				EndIf
				
			EndIf
			
			*cursorState\needRedraw = #True
		EndIf
	EndProcedure

	Procedure Event_Mouse(*te.TE_STRUCT, *view.TE_VIEW, event_type)
		ProcedureReturnIf((*te = #Null) Or (*view = #Null) Or (*te\currentCursor = #Null) Or (IsGadget(*view\canvas) = 0))
		
		
		Protected *cursorState.TE_CURSORSTATE = *te\cursorState
		
		*cursorState\needRedraw = #False
		*cursorState\time = ElapsedMilliseconds()
		*cursorState\mousePosition = #TE_MousePosition_TextArea
		*cursorState\canvasMouseX = GetGadgetAttribute(*view\canvas, #PB_Canvas_MouseX) * *view\zoom
		*cursorState\canvasMouseY = GetGadgetAttribute(*view\canvas, #PB_Canvas_MouseY) * *view\zoom
		*cursorState\buttons = GetGadgetAttribute(*view\canvas, #PB_Canvas_Buttons)
		*cursorState\modifiers = GetGadgetAttribute(*view\canvas, #PB_Canvas_Modifiers)
		*cursorState\mouseX = DesktopUnscaledX(*cursorState\canvasMouseX)
		*cursorState\mouseY = DesktopUnscaledY(*cursorState\canvasMouseY)
		*cursorState\windowMouseX = WindowMouseX(*te\window)
		*cursorState\windowMouseY = WindowMouseY(*te\window)
		*cursorState\deltaX = *cursorState\desktopMouseX - DesktopMouseX()
		*cursorState\deltaY = *cursorState\desktopMouseY - DesktopMouseY()
		*cursorState\desktopMouseX = DesktopMouseX()
		*cursorState\desktopMouseY = DesktopMouseY()
		
		Selection_Get(*te\currentCursor, *cursorState\selection)
		Selection_GetAll(*te, *cursorState\previousSelection)

		
		If *te\autoComplete\isVisible And
		   (*cursorState\mouseX > *te\autoComplete\x) And (*cursorState\mouseX < (*te\autoComplete\x + *te\autoComplete\width)) And
		   (*cursorState\mouseY > *te\autoComplete\y) And (*cursorState\mouseY < (*te\autoComplete\y + *te\autoComplete\height))
			If *cursorState\mouseX > (*te\autoComplete\x + *te\autoComplete\width - *te\autoComplete\scrollBarWidth)
				*cursorState\mousePosition = #TE_MousePosition_AutoCompleteScrollBar
			Else
				*cursorState\mousePosition = #TE_MousePosition_AutoComplete
			EndIf
		ElseIf GetFlag(*te, #TE_EnableLineNumbers) And (*cursorState\mouseX <= (*te\leftBorderOffset - *te\lineHeight))
			*cursorState\mousePosition = #TE_MousePosition_LineNumber
		ElseIf *cursorState\mouseX < *te\leftBorderOffset
			*cursorState\mousePosition = #TE_MousePosition_FoldState
		EndIf
		
		If *cursorState\dragDropMode > 0
			If *cursorState\modifiers & #PB_Canvas_Control
				*cursorState\dragDropMode = #TE_CursorState_DragCopy
			Else
				*cursorState\dragDropMode = #TE_CursorState_DragMove
			EndIf
		EndIf
		
		If (*cursorState\buttons & #PB_Canvas_LeftButton) = 0
			*cursorState\dragStart = #False
		EndIf
		
		CopyStructure(*te\currentCursor\position, *te\currentCursor\previousPosition, TE_POSITION)
		CopyStructure(*te\currentCursor\selection, *te\currentCursor\previousSelection, TE_POSITION)
		
		Select event_type
				
			Case #PB_EventType_LeftButtonDown
				
				If Event_Mouse_LeftButtonDown(*te, *view, *te\currentCursor)
					ProcedureReturn
				EndIf
				
			Case #PB_EventType_LeftButtonUp
				
				If Event_Mouse_LeftButtonUp(*te, *view, *te\currentCursor)
					ProcedureReturn
				EndIf
				
			Case #PB_EventType_LeftClick
				
				If (*cursorState\mousePosition = #TE_MousePosition_AutoCompleteScrollBar) And *te\autoComplete\height And (*te\autoComplete\scrollDistance = 0)
					Autocomplete_Scroll(*te, 0, (*cursorState\mouseY - *te\autoComplete\y) / *te\autoComplete\height)
					PostEvent(#TE_Event_Redraw, 0, 0, #TE_EventType_RedrawAll, *te\view)
					ProcedureReturn
				EndIf
				
			Case #PB_EventType_LeftDoubleClick
				
				If *cursorState\mousePosition = #TE_MousePosition_AutoComplete
					Autocomplete_Insert(*te)
					*te\redrawMode = #TE_Redraw_All
					PostEvent(#TE_Event_Redraw, 0, 0, #TE_EventType_RedrawAll, *te\view)
					ProcedureReturn
				EndIf
				
			Case #PB_EventType_RightButtonDown
				
				Autocomplete_Hide(*te.TE_STRUCT)
				
			Case #PB_EventType_RightButtonUp
				
				DisplayPopupMenu(*te\popupMenu, WindowID(*te\window))
				
			Case #PB_EventType_MiddleButtonDown
				
				Autocomplete_Hide(*te.TE_STRUCT)
				
			Case #PB_EventType_MouseMove
				
				If Event_Mouse_Move(*te, *view, *te\currentCursor)
					ProcedureReturn
				EndIf
				
		EndSelect
		
		If *te\needFoldUpdate
			Folding_Update(*te, -1, -1)
		EndIf
		If *te\needScrollUpdate
			Scroll_Update(*te, *te\currentView, *te\currentCursor, *te\currentCursor\position\visibleLineNr, -1, *te\needScrollUpdate)
			Scroll_UpdateAllViews(*te, *te\view, *te\currentView, *te\currentCursor)
		EndIf
		
		Selection_GetAll(*te, *cursorState\selection)
		If Position_Changed(*cursorState\selection\pos1, *cursorState\selection\pos2) Or Position_Changed(*cursorState\previousSelection\pos1, *cursorState\previousSelection\pos2)
			*te\redrawMode = #TE_Redraw_All
			If Position_Changed(*cursorState\selection\pos1, *cursorState\previousSelection\pos1) Or Position_Changed(*cursorState\selection\pos2, *cursorState\previousSelection\pos2)
				*te\redrawRange\pos1\lineNr = Min(*cursorState\selection\pos1\lineNr, *cursorState\previousSelection\pos1\lineNr)
				*te\redrawRange\pos2\lineNr = Max(*cursorState\selection\pos2\lineNr, *cursorState\previousSelection\pos2\lineNr)
				
				RepeatedSelection_Update(*te, *cursorState\selection\pos1\lineNr, *cursorState\selection\pos1\charNr, *cursorState\selection\pos2\lineNr, *cursorState\selection\pos2\charNr)
			EndIf
		EndIf
		
		If *te\needDictionaryUpdate
			Autocomplete_UpdateDictonary(*te, 0, 0)
		EndIf
		
		If *cursorState\needRedraw
			If *te\redrawMode & #TE_Redraw_All
				PostEvent(#TE_Event_Redraw, 0, 0, #TE_EventType_RedrawAll, *te\view)
			Else
				PostEvent(#TE_Event_Redraw, 0, 0, #TE_EventType_RedrawChangedLines, *te\view)
			EndIf
		EndIf
		
		Cursor_SignalChanges(*te, *te\currentCursor)
	EndProcedure
	
	Procedure Event_MouseWheel(*te.TE_STRUCT, *view.TE_VIEW, event_type)
		ProcedureReturnIf((*te = #Null) Or (*view = #Null) Or (IsGadget(*view\canvas) = 0))
		
		Protected mx = GetGadgetAttribute(*view\canvas, #PB_Canvas_MouseX)
		Protected my = GetGadgetAttribute(*view\canvas, #PB_Canvas_MouseY)
		Protected buttons = GetGadgetAttribute(*view\canvas, #PB_Canvas_Buttons)
		Protected modifiers = GetGadgetAttribute(*view\canvas, #PB_Canvas_Modifiers)
		Protected direction = GetGadgetAttribute(*view\canvas, #PB_Canvas_WheelDelta)
		
		If modifiers = #PB_Canvas_Control
			View_Zoom(*te, *view, direction)
		Else
			If modifiers & #PB_Canvas_Shift
				Scroll_Line(*te, *view, *te\currentCursor, *view\scroll\visibleLineNr - direction * 13)
			Else
				Scroll_Line(*te, *view, *te\currentCursor, *view\scroll\visibleLineNr - direction * 3)
			EndIf
			
			If (modifiers & #PB_Canvas_Alt) And (buttons & #PB_Canvas_LeftButton)
				If Cursor_FromScreenPos(*te, *view, *te\currentCursor, mx, my)
					Selection_SetRectangle(*te, *te\currentCursor)
				EndIf
			EndIf
		EndIf
		
		PostEvent(#TE_Event_Redraw, 0, 0, #TE_EventType_RedrawAll, *te\view)
	EndProcedure
	
	Procedure Event_ScrollBar()
		Protected gNr = EventGadget()
		If IsGadget(gnr) = 0
			ProcedureReturn
		EndIf
		
		Protected *view.TE_VIEW = GetGadgetData(gNr)
		ProcedureReturnIf((*view = #Null) Or (*view\editor = #Null))
		
		Protected *te.TE_STRUCT = *view\editor
		ProcedureReturnIf(*te = #Null)
		
		Protected previousLineNr = *view\scroll\visibleLineNr
		Protected previousCharX = *view\scroll\charX
		
		Autocomplete_Hide(*te.TE_STRUCT)
		
		If *te\currentCursor And (*view <> *te\currentView)
			*te\currentView = *view
			Scroll_Update(*te, *view, *te\currentCursor, *te\currentCursor\position\lineNr, *te\currentCursor\position\charNr)
		EndIf
		
		If gNr = *view\scrollBarV\gadget
			Scroll_Line(*te, *view, *te\currentCursor, GetGadgetState(gNr), #True, #False)
		EndIf
		
		If gNr = *view\scrollBarH\gadget
			Scroll_Char(*te, *view, Int(GetGadgetState(gNr) * *view\scrollBarH\scale))
		EndIf
		
		If (*view\scroll\visibleLineNr <> previousLineNr) Or (*view\scroll\charX <> previousCharX)
			PostEvent(#TE_Event_Redraw, 0, 0, #TE_EventType_RedrawAll, *te\view)
		EndIf
	EndProcedure
	
	Procedure Event_Timer()
		Protected *te.TE_STRUCT
		
		LockMutex(_PBEdit_Mutex)
		*te = _PBEdit_Window_\activeEditor
		UnlockMutex(_PBEdit_Mutex)
		
		ProcedureReturnIf((*te = #Null) Or (*te\currentView = #Null) Or (IsGadget(*te\currentView\canvas) = 0))
		
		Protected previousPos.TE_POSITION
		previousPos\visibleLineNr = *te\currentView\scroll\visibleLineNr
		previousPos\charX = *te\currentView\scroll\charX
		
		If EventTimer() = #TE_Timer_Scroll
			
			Protected *view.TE_VIEW = *te\currentView
			Protected position.TE_POSITION
			Protected yTop, yBottom, xLeft, xRight, scrollAmount, xSize, ySize
			Protected lineNr, *textLine.TE_TEXTLINE
			Protected time = ElapsedMilliseconds()
			Protected scrolling = #False
			
			lineNr = *te\currentCursor\position\lineNr
			
			If (time > *view\scroll\scrollTime) Or (*view\scroll\scrollDelay = 0)
				If *view\scroll\autoScrollV
					yTop = DesktopScaledY(GadgetY(*view\canvas, #PB_Gadget_ScreenCoordinate)) + (*te\lineHeight * 0.5) * *view\zoom
					yBottom = DesktopScaledY(GadgetY(*view\canvas, #PB_Gadget_ScreenCoordinate) + GadgetHeight(*view\canvas)) - (*te\lineHeight * 0.5) * *view\zoom
					
					If *te\cursorState\desktopMouseY < yTop
						ySize = Min(*te\lineHeight * 2, yTop - *te\cursorState\desktopMouseY)
						xSize = Min(25, Abs(*te\cursorState\deltaX))
						
						scrollAmount = Max(1, (ySize * 3) / (*te\lineHeight * 2.0)) + xSize
						scrolling = Scroll_Line(*te, *view, *te\currentCursor, *view\scroll\visibleLineNr - scrollAmount)
						lineNr = Textline_TopLine(*te)
						
						*view\scroll\scrollDelay = Clamp(250 - (ySize * 250) / (*te\lineHeight + xSize), 0, 250)
					ElseIf *te\cursorState\desktopMouseY > yBottom
						ySize = Min(*te\lineHeight * 2, *te\cursorState\desktopMouseY - yBottom)
						xSize = Min(25, Abs(*te\cursorState\deltaX))
						
						scrollAmount = Max(1, (ySize * 3) / (*te\lineHeight * 2.0)) + xSize
						scrolling = Scroll_Line(*te, *view, *te\currentCursor, *view\scroll\visibleLineNr + scrollAmount)
						lineNr = Textline_BottomLine(*te)
						
						*view\scroll\scrollDelay = Clamp(250 - (ySize * 250) / (*te\lineHeight + xSize), 0, 250)
					EndIf
				ElseIf *view\scroll\autoScrollH
					xLeft = DesktopScaledX(GadgetX(*view\canvas, #PB_Gadget_ScreenCoordinate) + *te\leftBorderOffset / *view\zoom)
					xRight = DesktopScaledX(GadgetX(*view\canvas, #PB_Gadget_ScreenCoordinate) + GadgetWidth(*view\canvas)) - (*te\lineHeight * 0.5) * *view\zoom
					
					If *te\cursorState\desktopMouseX < xLeft
						scrollAmount = Max(1, xLeft - *te\cursorState\desktopMouseX)
						Scroll_Update(*te, *view, *te\currentCursor, *te\currentCursor\position\visibleLineNr, *te\currentCursor\position\charNr - scrollAmount)
						
						*view\scroll\scrollDelay = Clamp(250 - scrollAmount * 50, 0, 250)
					ElseIf *te\cursorState\desktopMouseX > xRight
						scrollAmount = Max(1, *te\cursorState\desktopMouseX - xRight)
						Scroll_Update(*te, *view, *te\currentCursor, *te\currentCursor\position\visibleLineNr, *te\currentCursor\position\charNr + scrollAmount)
						
						*view\scroll\scrollDelay = Clamp(250 - scrollAmount * 50, 0, 250)
					EndIf
				EndIf
			EndIf
			
			If scrollAmount
				If Cursor_GetScreenPos(*te, *view, DesktopScaledX(*te\cursorState\mouseX), DesktopScaledY(*te\cursorState\mouseY), position)
					If *te\cursorState\dragDropMode = 0
						Cursor_Position(*te, *te\currentCursor, lineNr, position\charNr)
						*view\scroll\scrollTime = time + *view\scroll\scrollDelay
						
						If *te\cursorState\modifiers & #PB_Canvas_Alt
							Selection_SetRectangle(*te, *te\currentCursor)
						EndIf
					Else
						*te\cursorState\dragPosition\lineNr = position\lineNr
						*te\cursorState\dragPosition\charNr = position\charNr
					EndIf
				EndIf
				
				If (previousPos\visibleLineNr <> *te\currentView\scroll\visibleLineNr)  Or (previousPos\charX <> *te\currentView\scroll\charX)
					If GetFlag(*te, #TE_EnableSelection) = 0
						Selection_ClearAll(*te)
					EndIf
					
					Cursor_SignalChanges(*te, *te\currentCursor)
					
					PostEvent(#TE_Event_Redraw, 0, 0, #TE_EventType_RedrawAll, *te\view)
				EndIf
			EndIf
			
		EndIf
	EndProcedure
	
	Procedure Event_FindReplace()
		Protected flags, result
		Protected *te.TE_STRUCT 
		
		LockMutex(_PBEdit_Mutex)
		*te = _PBEdit_Window_\activeEditor
		UnlockMutex(_PBEdit_Mutex)
		
		ProcedureReturnIf((*te = #Null) Or (*te\currentView = #Null) Or (IsGadget(*te\currentView\canvas) = 0))
		
		Select Event()
				
			Case #PB_Event_CloseWindow
				
				If EventWindow() = *te\find\wnd_findReplace
					Find_Close(*te)
				EndIf
				
			Case #PB_Event_Menu
				
				If EventMenu() = #TE_Menu_EscapeKey
					Find_Close(*te)
				ElseIf EventMenu() = #TE_Menu_ReturnKey
					If Position_Equal(*te\currentCursor\position, *te\find\startPos)
						result = Find_Start(*te, *te\currentCursor, *te\currentCursor\position\lineNr, *te\currentCursor\position\charNr, GetGadgetText(*te\find\cmb_search), "", #TE_Find_Next)
					Else
						flags = Find_Flags(*te)
						result = Find_Start(*te, *te\currentCursor, 0, 0, GetGadgetText(*te\find\cmb_search), "", flags | #TE_Find_Next | #TE_Find_StartAtCursor)
					EndIf
				ElseIf EventMenu() = #TE_Menu_F3Key
					result = Find_Start(*te, *te\currentCursor, *te\currentCursor\position\lineNr, *te\currentCursor\position\charNr, GetGadgetText(*te\find\cmb_search), "", #TE_Find_Next)
				ElseIf EventMenu() = #TE_Menu_ShiftF3Key
					result = Find_Start(*te, *te\currentCursor, *te\currentCursor\position\lineNr, *te\currentCursor\position\charNr, GetGadgetText(*te\find\cmb_search), "", #TE_Find_Previous)
				EndIf
				
			Case #PB_Event_Gadget
				
				flags = Find_Flags(*te)
				
				Select EventGadget()
						
					Case *te\find\chk_regEx
						
						DisableGadget(*te\find\chk_caseSensitive, GetGadgetState(*te\find\chk_regEx))
						DisableGadget(*te\find\chk_wholeWords, GetGadgetState(*te\find\chk_regEx))
						
					Case *te\find\btn_close
						
						Find_Close(*te)
						
					Case *te\find\chk_replace
						
						If GetGadgetState(*te\find\chk_replace) = 1
							DisableGadget(*te\find\cmb_replace, 0)
							DisableGadget(*te\find\btn_replace, 0)
							DisableGadget(*te\find\btn_replaceAll, 0)
						Else
							DisableGadget(*te\find\cmb_replace, 1)
							DisableGadget(*te\find\btn_replace, 1)
							DisableGadget(*te\find\btn_replaceAll, 1)
						EndIf
						
					Case *te\find\btn_findNext
						
						If Position_Equal(*te\currentCursor\position, *te\find\startPos)
							result = Find_Start(*te, *te\currentCursor, *te\currentCursor\position\lineNr, *te\currentCursor\position\charNr, GetGadgetText(*te\find\cmb_search), "", #TE_Find_Next)
						Else
							result = Find_Start(*te, *te\currentCursor, 0, 0, GetGadgetText(*te\find\cmb_search), "", flags | #TE_Find_Next | #TE_Find_StartAtCursor)
						EndIf
						
					Case *te\find\btn_findPrevious
						
						If Position_Equal(*te\currentCursor\position, *te\find\startPos)
							result = Find_Start(*te, *te\currentCursor, *te\currentCursor\position\lineNr, *te\currentCursor\position\charNr, GetGadgetText(*te\find\cmb_search), "", #TE_Find_Previous)
						Else
							result = Find_Start(*te, *te\currentCursor, 0, 0, GetGadgetText(*te\find\cmb_search), "", flags | #TE_Find_Previous | #TE_Find_StartAtCursor)
						EndIf
						
					Case *te\find\btn_replace
						
						Undo_Start(*te, *te\undo)
						If GetGadgetState(*te\find\chk_replace) = 1
							If Cursor_HasSelection(*te\currentCursor)
								Cursor_SelectionStart(*te, *te\currentCursor)
							EndIf
							
							result = Find_Start(*te, *te\currentCursor, 0, 0, GetGadgetText(*te\find\cmb_search), GetGadgetText(*te\find\cmb_replace), flags | #TE_Find_Next | #TE_Find_Replace | #TE_Find_StartAtCursor)
							If result
								result = Find_Start(*te, *te\currentCursor, *te\currentCursor\position\lineNr, *te\currentCursor\position\charNr, GetGadgetText(*te\find\cmb_search), "", #TE_Find_Next)
							EndIf
						EndIf
						Undo_Update(*te)
						
					Case *te\find\btn_replaceAll
						
						Undo_Start(*te, *te\undo)
						If GetGadgetState(*te\find\chk_replace) = 1
							flags = Find_Flags(*te)
							result = Find_Start(*te, *te\currentCursor, 0, 0, GetGadgetText(*te\find\cmb_search), GetGadgetText(*te\find\cmb_replace), flags | #TE_Find_Next | #TE_Find_ReplaceAll)
							If result
								While Find_Next(*te, *te\currentCursor\position\lineNr, *te\currentCursor\position\charNr, *te\find\endPos\lineNr, *te\find\endPos\charNr, flags | #TE_Find_Next | #TE_Find_ReplaceAll)
								Wend
								Scroll_Line(*te, *te\currentView, *te\currentCursor, *te\currentCursor\position\lineNr - 3)
								*te\redrawMode = #TE_Redraw_All
								
								Cursor_SignalChanges(*te, *te\currentCursor)
							EndIf
							MessageRequester(*te\language\messageTitleFindReplace, ReplaceString(*te\language\messageReplaceComplete, "%N1", Str(*te\find\replaceCount)))
						EndIf
						Undo_Update(*te)
						
				EndSelect
		EndSelect
		
		If result
			Scroll_Update(*te, *te\currentView, *te\currentCursor, -1, -1)
			PostEvent(#TE_Event_Redraw, 0, 0, #TE_EventType_RedrawAll, *te\currentView)
		EndIf
	EndProcedure
	
	Procedure Event_Menu()
		Protected *te.TE_STRUCT
		
		LockMutex(_PBEdit_Mutex)
		*te = _PBEdit_Window_\activeEditor
		UnlockMutex(_PBEdit_Mutex)
		
		ProcedureReturnIf((*te = #Null) Or (*te\currentView = #Null) Or (IsGadget(*te\currentView\canvas) = 0))
		
		Protected menu = EventMenu()
		Protected undoIndex = Undo_Start(*te, *te\undo)
		
		CopyStructure(*te\currentCursor\selection, *te\currentCursor\previousSelection, TE_POSITION)
		CopyStructure(*te\currentCursor\position, *te\currentCursor\previousPosition, TE_POSITION)
		
		Select menu
			Case #TE_Menu_Cut
				ClipBoard_Cut(*te)
			Case #TE_Menu_Copy
				ClipBoard_Copy(*te)
			Case #TE_Menu_Paste
				ClipBoard_Paste(*te)
			Case #TE_Menu_SelectAll
				Selection_SelectAll(*te)
			Case #TE_Menu_InsertComment
				ForEach *te\cursor()
					Selection_Comment(*te, *te\cursor())
				Next
			Case #TE_Menu_RemoveComment
				ForEach *te\cursor()
					Selection_Uncomment(*te, *te\cursor())
				Next
			Case #TE_Menu_FormatIndentation
				If Selection_IsAnythingSelected(*te)
					Indentation_Range(*te, *te\currentCursor\position\lineNr, *te\currentCursor\selection\lineNr, #Null, #TE_Indentation_Auto)
				Else
					Indentation_Range(*te, *te\currentCursor\position\lineNr, *te\currentCursor\position\lineNr, #Null, #TE_Indentation_Auto)
				EndIf
				Cursor_Position(*te, *te\currentCursor, *te\currentCursor\position\lineNr, 1)
			Case #TE_Menu_ToggleFold
				Folding_Toggle(*te, *te\currentCursor\position\lineNr)
			Case #TE_Menu_ToggleAllFolds
				Folding_ToggleAll(*te)
			Case #TE_Menu_SplitViewHorizontal
				View_Split(*te, *te\cursorState\WindowMouseX, *te\cursorState\windowMouseY, #TE_View_SplitHorizontal)
			Case #TE_Menu_SplitViewVertical
				View_Split(*te, *te\cursorState\windowMouseX, *te\cursorState\windowMouseY, #TE_View_SplitVertical)
			Case #TE_Menu_UnsplitView
				View_Unsplit(*te, *te\cursorState\windowMouseX, *te\cursorState\windowMouseY)
			Case #TE_Menu_Beautify
				ForEach *te\cursor()
					Selection_Beautify(*te, *te\cursor())
				Next
		EndSelect
		
		If *te\needFoldUpdate
			Folding_Update(*te, -1, -1)
		EndIf	
		
		If *te\needScrollUpdate
			Scroll_Update(*te, *te\currentView, *te\currentCursor, -1, -1)
		EndIf
		
		Undo_Update(*te)
		If ListSize(*te\undo\entry()) > undoIndex
			Undo_Clear(*te\redo)
		EndIf
		
		PostEvent(#TE_Event_Redraw, 0, 0, #TE_EventType_RedrawAll, *te\view)
		
		Cursor_SignalChanges(*te, *te\currentCursor)
	EndProcedure
	
	Procedure Event_Drop()
		Protected gNr = EventGadget()
		If IsGadget(gnr) = 0
			ProcedureReturn
		EndIf
		
		Protected *view.TE_VIEW = GetGadgetData(gNr)
		ProcedureReturnIf((*view = #Null) Or (*view\editor = #Null))
		
		Protected *te.TE_STRUCT = *view\editor
		
		CopyStructure(*te\currentCursor\position, *te\cursorState\dragPosition, TE_POSITION)
		*te\cursorState\dragText = EventDropText()
		*te\cursorState\dragDropMode = #TE_CursorState_DragCopy
		
		DragDrop_Drop(*te)
	EndProcedure
	
	; 	Procedure Event_DropCallback(TargetHandle, State, Format, Action, x, y)
	; 		Protected gNr = GetActiveGadget();EventGadget()
	; 		If IsGadget(gnr) = 0 
	; 			ProcedureReturn #False
	; 		EndIf
	; 		
	; 		Protected *te.TE_STRUCT = GetGadgetData(gNr)
	; 		If (*te = #Null) Or GadgetType(*te\currentView\canvas) <> #PB_GadgetType_Canvas
	; 			ProcedureReturn #False
	; 		EndIf
	; 		
	; 		DragDrop_Start(*te)
	; 		
	;  		ProcedureReturn #False
	; 	EndProcedure
	
	Procedure Event_Gadget()
		Protected wNr = EventWindow()
		Protected gNr = EventGadget()
		If IsGadget(gnr) = 0
			ProcedureReturn
		EndIf
		
		Protected *view.TE_VIEW = GetGadgetData(gNr)
		ProcedureReturnIf((*view = #Null) Or (*view\editor = #Null))
		
		Protected *te.TE_STRUCT = *view\editor
		ProcedureReturnIf(*te = #Null)
		
		Select EventType()
				
			Case #PB_EventType_Resize
				
				; needed to avoid flickering of the screen when the gadget is resized
				*te\redrawMode = #TE_Redraw_All
				
			Case #PB_EventType_Input, #PB_EventType_KeyDown, #PB_EventType_KeyUp
				
				Event_Keyboard(*te, *view, EventType())
				
			Case #PB_EventType_LeftClick, #PB_EventType_LeftDoubleClick, #PB_EventType_LeftButtonDown, #PB_EventType_LeftButtonUp, #PB_EventType_RightButtonDown, #PB_EventType_RightButtonUp, #PB_EventType_MiddleButtonDown, #PB_EventType_MouseMove
				
				Event_Mouse(*te, *view, EventType())
				
			Case #PB_EventType_MouseWheel
				
				Event_MouseWheel(*te, *view, EventType())
				
			Case #PB_EventType_MiddleButtonUp
				
			Case #PB_EventType_Focus
				
				Editor_Activate(*te, #True, #False)
				
				If *te\currentCursor And (*view <> *te\currentView)
					*te\currentView = *view
					Scroll_Update(*te, *te\currentView, *te\currentCursor, *te\currentCursor\position\lineNr, *te\currentCursor\position\charNr)
				EndIf
				
			Case #PB_EventType_LostFocus
				
				Editor_Activate(*te, #False, #False)
				
			Case #PB_EventType_MouseEnter
				
			Case #PB_EventType_MouseLeave
				
		EndSelect
	EndProcedure
	
	Procedure Event_Cursor()
		Protected *te.TE_STRUCT = EventData()
		
		LockMutex(_PBEdit_Mutex)
		
		If *te And *te\isActive And *te\currentView And IsGadget(*te\currentView\canvas) And (*te\cursorState\dragDropMode = 0)
			If *te\cursorState\blinkSuspend
				*te\cursorState\blinkSuspend = 0
				*te\cursorState\blinkState = 1
			Else
				*te\cursorState\blinkState = Bool(Not *te\cursorState\blinkState)
			EndIf
			
			PushListPosition(*te\cursor())
			ForEach *te\cursor()
				If *te\cursor()\position\textline
					*te\cursor()\position\textline\needRedraw = #True
				EndIf
			Next
			PopListPosition(*te\cursor())
			
			PostEvent(#TE_Event_Redraw, 0, 0, #TE_EventType_RedrawChangedLines, *te\currentView)
		EndIf
		
		UnlockMutex(_PBEdit_Mutex)
	EndProcedure
	
	Procedure Event_Redraw()
		Protected *view.TE_VIEW = EventData()
		If *view
			Protected *te.TE_STRUCT = *view\editor
			If *te
				If EventType() = #TE_EventType_RedrawAll
					Draw(*te, *view, *te\cursorState\blinkState, #TE_Redraw_All)
				Else
					Draw(*te, *view, *te\cursorState\blinkState, #TE_Redraw_ChangedLines)
				EndIf
			EndIf
		EndIf
	EndProcedure
	
	DisableExplicit
EndModule

;-
;- ----------- FUNCTIONS -----------
;-

DeclareModule PBEdit
	Declare PBEdit_Gadget(WindowID, X, Y, Width, Height, LanguageFile$ = "")
	Declare PBEdit_FreeGadget(ID)
	Declare PBEdit_IsGadget(ID)
	Declare PBEdit_Container(ID)
	Declare PBEdit_LoadSettings(ID, Path$)
	Declare PBEdit_LoadStyle(ID, Path$, ClearKeywords = #True)
	Declare PBEdit_EnableAutoRedraw(ID, Enabled)
	Declare PBEdit_Activate(ID)
	Declare PBEdit_SetGadgetFont(ID, FontName$, FontHeight = 0, FontStyle = 0)
	Declare PBEdit_Resize(ID, X, Y, Width, Height)
	Declare PBEdit_GetWindow(ID)
	Declare PBEdit_Update(ID)
	
	Declare PBEdit_CountGadgetItems(ID)
	Declare PBEdit_AddGadgetItem(ID, Position, Text$)
	Declare.s PBEdit_GetGadgetText(ID)
	Declare.s PBEdit_GetGadgetItemText(ID, Position)
	Declare PBEdit_SetGadgetText(ID, Text$)
	Declare PBEdit_SetGadgetItemText(ID, Position, Text$)
	Declare PBEdit_RemoveGadgetItem(ID, Position)
	Declare PBEdit_ClearGadgetItems(ID)
	
	Declare PBEdit_GetCursorLineNr(ID)
	Declare PBEdit_GetCursorCharNr(ID)
	Declare PBEdit_GetCursorColumnNr(ID)
	Declare PBEdit_GetSelectionLineNr(ID)
	Declare PBEdit_GetSelectionCharNr(ID)
	Declare PBEdit_GetSelectionCharCount(ID)
	Declare.s PBEdit_GetSelectedText(ID)
	Declare PBEdit_GetCursorCount(ID)
	Declare PBEdit_SetCursorPosition(ID, LineNr, charNr)
	Declare PBEdit_SetSelection(ID, LineNr, charNr)
	Declare PBEdit_SetText(ID, Text$)
	
	Declare PBEdit_SetRemark(ID, LineNr, Text$, Type)
	Declare PBEdit_ClearRemarks(ID)
	Declare PBEdit_SetMarker(ID, LineNr, MarkerType)
	Declare PBEdit_ClearMarkers(ID)
	
	Declare PBEdit_SetFlag(ID, Flag, Value)
	Declare PBEdit_GetFlag(ID, Flag)
	
	Declare PBEdit_Undo(ID)
	Declare PBEdit_Redo(ID)
EndDeclareModule

Module PBEdit
	UseModule _PBEdit_
	
	Global Redraw.i
	Global NewMap IDMap()
	
	Procedure PBEdit_Gadget(WindowID, X, Y, Width, Height, LanguageFile$ = "")
		Protected ID = Editor_New(WindowID, X, Y, Width, Height, LanguageFile$)
		
		If ID
			IDMap(Hex(ID)) = ID
			Redraw = #True
		EndIf
		
		ProcedureReturn ID
	EndProcedure
	
	Procedure PBEdit_IsGadget(ID)
		ProcedureReturn IDMap(Hex(ID))
	EndProcedure
	
	Procedure PBEdit_FreeGadget(ID)
		Protected *te.TE_STRUCT = PBEdit_IsGadget(ID)
		If *te
			Editor_Free(*te)
			DeleteMapElement(IDMap(), Hex(ID))
		EndIf
	EndProcedure
	
	Procedure PBEdit_Container(ID)
		Protected *te.TE_STRUCT = PBEdit_IsGadget(ID)
		If *te
			ProcedureReturn *te\container
		EndIf
	EndProcedure
	
	Procedure PBEdit_Redraw(*te.TE_STRUCT)
		If Redraw
			*te\redrawMode = #TE_Redraw_All
		EndIf
	EndProcedure
	
	Procedure PBEdit_Update(ID)
		Protected *te.TE_STRUCT = PBEdit_IsGadget(ID)
		If *te
			Scroll_Update(*te, *te\currentView, *te\currentCursor, 0, 0)
			Folding_Update(*te, -1, -1)
		EndIf
	EndProcedure
	
	Procedure PBEdit_Activate(ID)
		Protected *te.TE_STRUCT = PBEdit_IsGadget(ID)
		If *te And *te\currentView And IsGadget(*te\currentView\canvas)
			Editor_Activate(*te, #True)
		EndIf
	EndProcedure
	
	Procedure PBEdit_EnableAutoRedraw(ID, Enabled)
		Protected *te.TE_STRUCT = PBEdit_IsGadget(ID)
		Redraw = Bool(Enabled > 0)
		If *te And Redraw
			Scroll_Update(*te, *te\currentView, *te\currentCursor, 0, 0)
			PBEdit_Redraw(*te)
		EndIf
	EndProcedure
	
	Procedure PBEdit_LoadSettings(ID, Path$)
		Protected *te.TE_STRUCT = PBEdit_IsGadget(ID)
		If *te
			Settings_OpenXml(*te, Path$)
		EndIf
	EndProcedure
	
	Procedure PBEdit_LoadStyle(ID, Path$, ClearKeywords = #True)
		Protected *te.TE_STRUCT = PBEdit_IsGadget(ID)
		If *te
			Styling_OpenXml(*te, Path$, ClearKeywords)
		EndIf
	EndProcedure
	
	Procedure PBEdit_SetGadgetFont(ID, FontName$, FontSize = 0, FontStyle = 0)
		Protected *te.TE_STRUCT = PBEdit_IsGadget(ID)
		If *te
			If FontSize <= 0
				FontSize = 11
			EndIf
			
			Style_SetFont(*te, FontName$, FontSize, FontStyle)
		EndIf
	EndProcedure
	
	Procedure PBEdit_Resize(ID, X, Y, Width, Height)
		Protected *te.TE_STRUCT = PBEdit_IsGadget(ID)
		If *te
			Editor_Resize(*te, X, Y, Width, Height)
		EndIf
	EndProcedure
	
	Procedure PBEdit_GetWindow(ID)
		Protected *te.TE_STRUCT = PBEdit_IsGadget(ID)
		If *te
			ProcedureReturn *te\window
		EndIf
	EndProcedure
	
	Procedure PBEdit_CountGadgetItems(ID)
		Protected *te.TE_STRUCT = PBEdit_IsGadget(ID)
		If *te
			ProcedureReturn ListSize(*te\textLine())
		EndIf
	EndProcedure
	
	Procedure PBEdit_AddGadgetItem(ID, Position, Text$)
		Protected *te.TE_STRUCT = PBEdit_IsGadget(ID)
		If *te
			Protected lineNr
			
			Undo_Start(*te, *te\undo)
			If Position < 0
				Position = *te\currentCursor\position\lineNr - 1
			EndIf
			If Textline_FromLine(*te, Position + 1)
				If lineNr < ListSize(*te\textLine())
					Text$ = Text$ + *te\newLineText
				Else
					Text$ = *te\newLineText + Text$
				EndIf
				Cursor_Position(*te, *te\currentCursor, Position + 1, 1)
				Textline_AddText(*te, *te\currentCursor, @Text$, Len(Text$), #TE_Styling_All, *te\undo)
			EndIf
			Undo_Update(*te)
			
			Folding_Update(*te, -1, -1)
			
			If Redraw
				Scroll_Update(*te, *te\currentView, *te\currentCursor, 0, 0)
			EndIf
			
			Selection_Clear(*te, *te\currentCursor)
			PBEdit_Redraw(*te)
		EndIf
	EndProcedure
	
	Procedure.s PBEdit_GetGadgetText(ID)
		Protected *te.TE_STRUCT = PBEdit_IsGadget(ID)
		If *te
			ProcedureReturn Text_Get(*te, 1, 1, ListSize(*te\textLine()), Textline_Length(LastElement(*te\textLine())) + 1)
		EndIf
	EndProcedure
	
	Procedure.s PBEdit_GetGadgetItemText(ID, Position)
		Protected *te.TE_STRUCT = PBEdit_IsGadget(ID)
		If *te
			If Textline_FromLine(*te, Position + 1)
				ProcedureReturn *te\textLine()\text
			EndIf
		EndIf
		ProcedureReturn ""
	EndProcedure
	
	Procedure PBEdit_SetGadgetText(ID, Text$)
		Protected *te.TE_STRUCT = PBEdit_IsGadget(ID)
		If *te
			Undo_Start(*te, *te\undo)
			Selection_SelectAll(*te)
			Selection_Delete(*te, *te\currentCursor, *te\undo)
			If FirstElement(*te\textLine())
				Textline_AddText(*te, *te\currentCursor, @Text$, Len(Text$), #TE_Styling_UpdateFolding | #TE_Styling_UpdateIndentation, *te\undo)
			EndIf
			Folding_Update(*te, -1, -1)
			Scroll_Update(*te, *te\currentView, *te\currentCursor, -1, -1)
			Undo_Update(*te)
			PBEdit_Redraw(*te)
		EndIf
	EndProcedure
		
	Procedure PBEdit_SetGadgetItemText(ID, Position, Text$)
		Protected *te.TE_STRUCT = PBEdit_IsGadget(ID)
		If *te
			If Textline_FromLine(*te, Position + 1)
				Undo_Start(*te, *te\undo)
				Textline_SetText(*te, *te\textLine(), Text$, #TE_Styling_All, *te\undo)
				Cursor_Position(*te, *te\currentCursor, ListIndex(*te\textLine()) + 1, Len(Text$) + 1)
				Selection_Clear(*te, *te\currentCursor)
				Undo_Update(*te)
				PBEdit_Redraw(*te)
			EndIf
		EndIf
	EndProcedure
	
	Procedure PBEdit_RemoveGadgetItem(ID, Position)
		Protected *te.TE_STRUCT = PBEdit_IsGadget(ID)
		If *te
			If Textline_FromLine(*te, Position + 1)
				Undo_Start(*te, *te\undo)
				Cursor_Position(*te, *te\currentCursor, ListIndex(*te\textLine()), 1)
				Selection_SetRange(*te, *te\currentCursor, *te\currentCursor\position\lineNr + 1, 1)
				Selection_Delete(*te, *te\currentCursor, *te\undo)
				Undo_Update(*te)
				
				Folding_Update(*te, -1, -1)
				
				If Redraw
					Scroll_Update(*te, *te\currentView, *te\currentCursor, 0, 0)
				EndIf
				
				Selection_Clear(*te, *te\currentCursor)
				
				PBEdit_Redraw(*te)
			EndIf
		EndIf
	EndProcedure
	
	Procedure PBEdit_ClearGadgetItems(ID)
		Protected *te.TE_STRUCT = PBEdit_IsGadget(ID)
		If *te
			Selection_SelectAll(*te)
			Selection_Delete(*te, *te\currentCursor)
		EndIf
	EndProcedure
	
	Procedure PBEdit_GetCursorColumnNr(ID)
		Protected *te.TE_STRUCT = PBEdit_IsGadget(ID)
		If *te And *te\currentView And *te\currentCursor
			ProcedureReturn Textline_ColumnFromCharNr(*te, *te\currentView, *te\currentcursor\position\textline, *te\currentCursor\position\charNr)
		EndIf
		ProcedureReturn 0
	EndProcedure
	
	Procedure PBEdit_SetCursorPosition(ID, LineNr, charNr)
		Protected *te.TE_STRUCT = PBEdit_IsGadget(ID)
		If *te
			Cursor_Position(*te, *te\currentCursor, LineNr, charNr)
			PBEdit_Redraw(*te)
		EndIf
	EndProcedure
	
	Procedure PBEdit_SetSelection(ID, LineNr, charNr)
		Protected *te.TE_STRUCT = PBEdit_IsGadget(ID)
		If *te
			If LineNr < 1
				Selection_Clear(*te, *te\currentCursor)
			Else
				Selection_SetRange(*te, *te\currentCursor, LineNr, charNr)
			EndIf
			PBEdit_Redraw(*te)
		EndIf
	EndProcedure
	
	Procedure.s PBEdit_GetSelectedText(ID)
		Protected *te.TE_STRUCT = PBEdit_IsGadget(ID)
		If *te
			Protected selection.TE_RANGE
			If Selection_Get(*te\currentCursor, selection)
				ProcedureReturn Text_Get(*te, selection\pos1\lineNr, selection\pos1\charNr, selection\pos2\lineNr, selection\pos2\charNr)
			EndIf
		EndIf
		ProcedureReturn ""
	EndProcedure
	
	Procedure PBEdit_SetRemark(ID, LineNr, Text$, Type)
		Protected *te.TE_STRUCT = PBEdit_IsGadget(ID)
		If *te
			Textline_AddRemark(*te, LineNr, Type, Text$, *te\undo)
			PBEdit_Redraw(*te)
		EndIf
	EndProcedure
	
	Procedure PBEdit_ClearRemarks(ID)
		Protected *te.TE_STRUCT = PBEdit_IsGadget(ID)
		If *te
			Remark_Clear(*te)
			PBEdit_Redraw(*te)
		EndIf
	EndProcedure
	
	Procedure PBEdit_SetText(ID, Text$)
		Protected *te.TE_STRUCT = PBEdit_IsGadget(ID)
		If *te And *te\currentCursor
			Undo_Start(*te, *te\undo)
			Selection_Delete(*te, *te\currentCursor, *te\undo)
			Textline_AddText(*te, *te\currentCursor, @Text$, Len(Text$), #TE_Styling_All, *te\undo)
			Selection_Clear(*te, *te\currentCursor)
			Undo_Update(*te)
			
			Folding_Update(*te, 0, 0)
			
			If Redraw
				Scroll_Update(*te, *te\currentView, *te\currentCursor, 0, 0)
			EndIf
			
			PBEdit_Redraw(*te)
		EndIf
	EndProcedure
	
	Procedure PBEdit_GetCursorLineNr(ID)
		Protected *te.TE_STRUCT = PBEdit_IsGadget(ID)
		If *te And *te\currentCursor And *te\currentCursor\position\textline
			ProcedureReturn *te\currentCursor\position\textline\lineNr
		EndIf
		ProcedureReturn 0
	EndProcedure
	
	Procedure PBEdit_GetCursorCharNr(ID)
		Protected *te.TE_STRUCT = PBEdit_IsGadget(ID)
		If *te And *te\currentCursor
			ProcedureReturn *te\currentCursor\position\charNr
		EndIf
		ProcedureReturn 0
	EndProcedure
	
	Procedure PBEdit_GetSelectionLineNr(ID)
		Protected *te.TE_STRUCT = PBEdit_IsGadget(ID)
		If *te And *te\currentCursor
			ProcedureReturn *te\currentCursor\selection\lineNr
		EndIf
		ProcedureReturn 0
	EndProcedure
	
	Procedure PBEdit_GetSelectionCharNr(ID)
		Protected *te.TE_STRUCT = PBEdit_IsGadget(ID)
		If *te And *te\currentCursor
			ProcedureReturn *te\currentCursor\selection\charNr
		EndIf
		ProcedureReturn 0
	EndProcedure
	
	Procedure PBEdit_GetSelectionCharCount(ID)
		Protected *te.TE_STRUCT = PBEdit_IsGadget(ID)
		If *te And *te\currentCursor
			ProcedureReturn Selection_CharCount(*te, *te\currentCursor)
		EndIf
		ProcedureReturn 0
	EndProcedure
	
	Procedure PBEdit_GetCursorCount(ID)
		Protected *te.TE_STRUCT = PBEdit_IsGadget(ID)
		If *te
			ProcedureReturn ListSize(*te\cursor())
		EndIf
		ProcedureReturn 0
	EndProcedure
	
	Procedure PBEdit_SetMarker(ID, LineNr, MarkerType)
		Protected *te.TE_STRUCT = PBEdit_IsGadget(ID)
		If *te
			Marker_Add(*te, Textline_FromLine(*te, LineNr), MarkerType)
		EndIf
		ProcedureReturn 0
	EndProcedure
	
	Procedure PBEdit_ClearMarkers(ID)
		Protected *te.TE_STRUCT = PBEdit_IsGadget(ID)
		If *te
			Marker_ClearAll(*te)
		EndIf
		ProcedureReturn 0
	EndProcedure
	
	Procedure PBEdit_SetFlag(ID, Flag, Value)
		Protected *te.TE_STRUCT = PBEdit_IsGadget(ID)
		Protected oldValue
		If *te
			oldValue = GetFlag(*te, Flag)
			SetFlag(*te, Flag, Value)
		EndIf
		ProcedureReturn oldValue
	EndProcedure
	
	Procedure PBEdit_GetFlag(ID, Flag)
		Protected *te.TE_STRUCT = PBEdit_IsGadget(ID)
		If *te
			ProcedureReturn GetFlag(*te, Flag)
		EndIf
		ProcedureReturn 0
	EndProcedure
	
	Procedure PBEdit_Undo(ID)
		Protected *te.TE_STRUCT = PBEdit_IsGadget(ID)
		If *te
			If Undo_Do(*te, *te\undo, *te\redo)
				PBEdit_Redraw(*te)
			EndIf
		EndIf
	EndProcedure
	
	Procedure PBEdit_Redo(ID)
		Protected *te.TE_STRUCT = PBEdit_IsGadget(ID)
		If *te
			If Undo_Do(*te, *te\redo, *te\undo)
				PBEdit_Redraw(*te)
			EndIf
		EndIf
	EndProcedure
	
	UnuseModule _PBEdit_
EndModule


CompilerIf #PB_Compiler_IsMainFile
	; *** TEST *** TEST *** TEST *** TEST *** TEST *** TEST *** TEST *** TEST *** TEST 
	
	Procedure UndoImage(angle)
		Protected i = CreateImage(#PB_Any, 24, 24, 32, #PB_Image_Transparent)
		If IsImage(i)
			If StartVectorDrawing(ImageVectorOutput(i))
				RotateCoordinates(12,12,angle)
				AddPathSegments("M 2 10 L 12 10 L 12 7 L 23 12 L 12 17 L 12 14 L 2 14 Z")
				VectorSourceColor(RGBA(16,16,16,255))
				FillPath()
				StopVectorDrawing()
			EndIf
		EndIf
		ProcedureReturn i
	EndProcedure
		
	Enumeration 1
		#tlb_undo
		#tlb_redo
	EndEnumeration
	
	UseModule PBEdit
	
	OpenWindow(0, 0, 0, 800, 600, AppTitle$, #PB_Window_SystemMenu | #PB_Window_SizeGadget | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_Maximize)
	
	CreateToolBar(0, WindowID(0), #PB_ToolBar_Large)
	ToolBarImageButton(#tlb_undo, ImageID(UndoImage(180)))
	ToolBarImageButton(#tlb_redo, ImageID(UndoImage(0)))
	CreateStatusBar(0, WindowID(0))
	AddStatusBarField(#PB_Ignore)
	AddStatusBarField(#PB_Ignore)
	AddStatusBarField(#PB_Ignore)
	AddStatusBarField(#PB_Ignore)
	WindowBounds(0, 100, 100, #PB_Ignore, #PB_Ignore)
	
	editor = PBEdit_Gadget(0, 5, ToolBarHeight(0), WindowWidth(0) - 10, WindowHeight(0) - (ToolBarHeight(0) + StatusBarHeight(0) + 5))
	If PBEdit_IsGadget(editor) = 0
		MessageRequester("", "Failed to create PBEdit Gadget", #PB_MessageRequester_Error)
		End
	EndIf
	
	PBEdit_LoadSettings(editor, #PB_Compiler_FilePath + "styles\PBEdit_PureBasic.settings")
	PBEdit_LoadStyle(editor, #PB_Compiler_FilePath + "styles\PBEdit_PureBasic.style")
	
	PBEdit_SetFlag(editor, _PBEdit_::#TE_EnableDictionary, 0)
	
	If ReadFile(0, #PB_Compiler_Filename, #PB_File_SharedRead)
		PBEdit_SetText(editor, ReadString(0, #PB_File_IgnoreEOL))
		CloseFile(0)
	EndIf
	
	Repeat
		Select WaitWindowEvent()
			Case #PB_Event_CloseWindow
				If EventWindow() = PBEdit_GetWindow(editor)
					PBEdit_FreeGadget(editor)
					End
				EndIf
			Case #PB_Event_ActivateWindow
				If EventWindow() = PBEdit_GetWindow(editor)
					PBEdit_Activate(editor)
				EndIf
			Case #PB_Event_SizeWindow
				If EventWindow() = PBEdit_GetWindow(editor)
					PBEdit_Resize(editor, #PB_Ignore, #PB_Ignore, WindowWidth(0) - 10, WindowHeight(0) - (ToolBarHeight(0) + StatusBarHeight(0) + 5))
				EndIf
			Case #PB_Event_Menu
				If EventMenu() = #tlb_undo
					PBEdit_Undo(editor)
				ElseIf EventMenu() = #tlb_redo
					PBEdit_Redo(editor)
				EndIf				
				; --- custom events ---
			Case _PBEdit_::#TE_Event_Cursor
				If EventType() = _PBEdit_::#TE_EventType_Change
					StatusBarText(0, 0, "Line: " + Str(PBEdit_GetCursorLineNr(editor)) + 
					                    "  Column: " + Str(PBEdit_GetCursorColumnNr(editor)) + 
					                    "  (Char: " + Str(PBEdit_GetCursorCharNr(editor)) + ")")
					
				ElseIf EventType() = _PBEdit_::#TE_EventType_Add Or EventType() = _PBEdit_::#TE_EventType_Remove
					StatusBarText(0, 2, "Cursors: " + Str(PBEdit_GetCursorCount(editor)))
				EndIf
			Case _PBEdit_::#TE_Event_Selection
				If EventType() = _PBEdit_::#TE_EventType_Remove
					StatusBarText(0, 1, "")
				ElseIf EventType() = _PBEdit_::#TE_EventType_Change
					StatusBarText(0, 1, "Selection [" + 
					                    Str(Abs(PBEdit_GetSelectionLineNr(editor) - PBEdit_GetCursorLineNr(editor)) + 1) + ", " +
					                    Str(PBEdit_GetSelectionCharCount(editor)) + "]")
				EndIf
		EndSelect
	ForEver
CompilerEndIf
; IDE Options = PureBasic 6.01 LTS beta 3 (Windows - x64)
; CursorPosition = 152
; FirstLine = 136
; Folding = -------------------------------------------------
; Optimizer
; EnableXP
; DPIAware