-- ������ : �̻��
-- ��� �� ������ �����Դϴ�. ������ �� ������ �����մϴ�.

global SoxSkinHideManager		-- �Ѿƿ����� �۷ι� ������ �ν��ϱ� ���� �ʱ⿡ �� �� ���

try (destroydialog SoxSkinHideManager) catch()		-- Ȥ�� �����ִ� â�� ������ ���� ����

rollout SoxSkinHideManager "Sox SkinHideManager v0.30" width:180
(
	group "Hide Selected"
	(
		button uiBtnHideSelVerts "Vertex" align:#left across:3
		button uiBtnHideSelFace "Face" align:#center offset:[-3, 0]
		button uiBtnHideSelElem "Element" align:#right
	)
	
	button uiBtnUnhideAll "Unhide All"
	
	group "Option"
	(
		checkbox uiChkHideUnselected "Hide Unselected" across:2
		button uiBtnAbout "About" offset:[20, -4]
	)

	-- obj�� ��Ų ������̾ ����Ǿ����� �˻��Ͽ� �ش� ������̾� ��ġ id ��ȣ�� �����Ѵ�. ������̾ ������ 0 ����
	function CheckSkinModifier obj =
	(
		if ( obj.modifiers.count == 0 ) do return 0
		for o = 1 to obj.modifiers.count do
		(
			if ( (classof obj.modifiers[o])  == Skin ) do return o
		)
		return 0
	)
	
	-- Skin ������̾ ����� Ÿ���� �˾Ƴ���. (����� ���� Ÿ�Ը� ����)
	-- Teapot ������Ʈ�� ���� ���,
	-- 0. ���� ���
	-- 1. Teapot > Skin
	-- 2. Teapot > ?? .... > Edit Poly > Skin  (Skin�� Edit Poly ���̿� �ٸ� ���� �������� �� �ִ�)
	-- 3. Edittable Poly > Skin (Edit Poly ������̾ �������� ����)
	-- �� �Լ��� Skin�� ����Ǿ��ִٴ� ���� �Ͽ� �۵�
	local idEditPolyModifier
	local idSkinModifier
	function CheckType obj =
	(
		idSkinModifier = CheckSkinModifier obj
		if idSkinModifier == 0 do return 0
		
		-- 1�� Ȥ�� 3�� ���
		if ( obj.modifiers.count == 1 ) do (
			if ( (classof $.baseobject) == Editable_Poly ) then
			(
				return 3
			)
			else
			(
				return 1
			)
		)
		
		-- ���� 2�� Ȥ�� 3��
		-- �ϴ� Skin ������̾ �ִ� ��ġ�� ã�´�.
		idSkin = CheckSkinModifier obj
		
		for o = idSkin to obj.modifiers.count do
		(
			if ( ( classof obj.modifiers[o] ) == Edit_Poly ) do
			(
				idEditPolyModifier = o		-- �߰ߵ� Edit Poly ������̾� �ε����� ���� ������ ���
				return 2
			)
		)
		
		if ( ( classof obj.baseobject ) == Editable_Poly ) do return 3
		
		-- � ��쿡�� �ش���� ������ 0 ����
		return 0
	)
	
	-- ��Ų ������̾�κ��� ���� ���õ� ���ý� �Ϸù�ȣ�� bitArray �� �����Ѵ�.
	function GetSkinVertSelection skinMod =
	(
		bitArr = #{}
		loopIndex = 1
		errFlag = false
		testValue = true
		while errFlag == false do
		(
			try
			(
				testValue = skinOps.IsVertexSelected skinMod loopIndex
			)
			catch
			(
				return bitArr
			)
			
			append bitArr loopIndex
			if testValue == 0 do
			(
				bitArr[loopIndex] = false
			)
			loopIndex += 1
		)
		return bitArr
	)
	
	on uiBtnHideSelVerts pressed do
	(
		if (selection.count != 1) do return()
			
		-- ���⼭ idSkinModifier�� idEditPolyModifier ���� ������ ���� ���õȴ�.	
		skinType = CheckType selection[1]
						
		if ( skinType == 0 ) do return()
		
		disableSceneRedraw()
		undo on (
		case skinType of
		(
			2:
			(
				-- Edit Poly > Skin
				selectedVerts = GetSkinVertSelection selection[1].modifiers[idSkinModifier]
				if (uiChkHideUnselected.state) do
				(
					selectedVerts = -selectedVerts
				)
				modPanel.setCurrentObject selection[1].modifiers[idEditPolyModifier]
				subobjectLevel = 1
				selection[1].modifiers[idEditPolyModifier].SetSelection #Vertex #{}
				selection[1].modifiers[idEditPolyModifier].Select #Vertex selectedVerts
				selection[1].modifiers[idEditPolyModifier].ButtonOp #HideVertex
				subobjectLevel = 0
				modPanel.setCurrentObject selection[1].modifiers[idSkinModifier]
				subobjectLevel = 1
				skinOps.SelectVertices selection[1].modifiers[idSkinModifier] #{}
			)-- 2 end
			
			3:
			(
				-- Edittable Poly > Skin
				selectedVerts = GetSkinVertSelection selection[1].modifiers[idSkinModifier]
				if (uiChkHideUnselected.state) do
				(
					selectedVerts = -selectedVerts
				)
				selection[1].EditablePoly.SetSelection #Vertex selectedVerts
				selection[1].EditablePoly.Hide #Vertex
				subobjectLevel = 1
				skinOps.SelectVertices selection[1].modifiers[idSkinModifier] #{}
			)-- 3 end
			
			default: return ()
		)
		)-- undo end
		enableSceneRedraw()
	)
	
	on uiBtnHideSelFace pressed do
	(
		if (selection.count != 1) do return()
			
		-- ���⼭ idSkinModifier�� idEditPolyModifier ���� ������ ���� ���õȴ�.	
		skinType = CheckType selection[1]
						
		if ( skinType == 0 ) do return()
		
		disableSceneRedraw()
		undo on (
		case skinType of
		(
			2:
			(
				-- Edit Poly > Skin
				selectedVerts = GetSkinVertSelection selection[1].modifiers[idSkinModifier]
				modPanel.setCurrentObject selection[1].modifiers[idEditPolyModifier]
				subobjectLevel = 1
				selection[1].modifiers[idEditPolyModifier].SetSelection #Vertex #{}
				selection[1].modifiers[idEditPolyModifier].Select #Vertex selectedVerts
				selection[1].modifiers[idEditPolyModifier].ConvertSelection #Vertex #Face
				if (uiChkHideUnselected.state) do
				(
					subobjectLevel = 4
					actionMan.executeAction 0 "40044"  -- Selection: Select Invert
				)
				selection[1].modifiers[idEditPolyModifier].ButtonOp #HideFace
				subobjectLevel = 0
				modPanel.setCurrentObject selection[1].modifiers[idSkinModifier]
				subobjectLevel = 1
				skinOps.SelectVertices selection[1].modifiers[idSkinModifier] #{}
			)-- 2 end
			
			3:
			(
				-- Edittable Poly > Skin
				selectedVerts = GetSkinVertSelection selection[1].modifiers[idSkinModifier]
				selection[1].EditablePoly.SetSelection #Vertex selectedVerts
				selection[1].EditablePoly.ConvertSelection #Vertex #Face
				if (uiChkHideUnselected.state) do
				(
					modPanel.setCurrentObject selection[1].baseObject
					subobjectLevel = 4
					actionMan.executeAction 0 "40044"  -- Selection: Select Invert
					subobjectLevel = 0
				)
				selection[1].EditablePoly.Hide #Face
				modPanel.setCurrentObject selection[1].modifiers[idSkinModifier]
				subobjectLevel = 1
				skinOps.SelectVertices selection[1].modifiers[idSkinModifier] #{}
			)-- 3 end
			
			default: return ()
		)
		)-- undo end
		enableSceneRedraw()
	)
	
	on uiBtnHideSelElem pressed do
	(
		if (selection.count != 1) do return()
			
		-- ���⼭ idSkinModifier�� idEditPolyModifier ���� ������ ���� ���õȴ�.	
		skinType = CheckType selection[1]
						
		if ( skinType == 0 ) do return()
		
		disableSceneRedraw()
		undo on (
		case skinType of
		(
			2:
			(
				-- Edit Poly > Skin
				selectedVerts = GetSkinVertSelection selection[1].modifiers[idSkinModifier]
				modPanel.setCurrentObject selection[1].modifiers[idEditPolyModifier]
				subobjectLevel = 1
				selection[1].modifiers[idEditPolyModifier].SetSelection #Vertex #{}
				selection[1].modifiers[idEditPolyModifier].Select #Vertex selectedVerts
				selection[1].modifiers[idEditPolyModifier].ConvertSelection #Vertex #Element
				if (uiChkHideUnselected.state) do
				(
					subobjectLevel = 5
					actionMan.executeAction 0 "40044"  -- Selection: Select Invert
				)
				selection[1].modifiers[idEditPolyModifier].ButtonOp #HideFace
				subobjectLevel = 0
				modPanel.setCurrentObject selection[1].modifiers[idSkinModifier]
				subobjectLevel = 1
				skinOps.SelectVertices selection[1].modifiers[idSkinModifier] #{}
			)-- 2 end
			
			3:
			(
				-- Edittable Poly > Skin
				selectedVerts = GetSkinVertSelection selection[1].modifiers[idSkinModifier]
				selection[1].EditablePoly.SetSelection #Vertex selectedVerts
				selection[1].EditablePoly.ConvertSelection #Vertex #Element
				if (uiChkHideUnselected.state) do
				(
					modPanel.setCurrentObject selection[1].baseObject
					subobjectLevel = 5
					actionMan.executeAction 0 "40044"  -- Selection: Select Invert
					subobjectLevel = 0
				)
				selection[1].EditablePoly.Hide #Face
				modPanel.setCurrentObject selection[1].modifiers[idSkinModifier]
				subobjectLevel = 1
				skinOps.SelectVertices selection[1].modifiers[idSkinModifier] #{}
			)-- 3 end
			
			default: return ()
		)
		)-- undo end
		enableSceneRedraw()
	)
	
	on uiBtnUnhideAll pressed do
	(
		if (selection.count != 1) do return()
			
		-- ���⼭ idSkinModifier�� idEditPolyModifier ���� ������ ���� ���õȴ�.	
		skinType = CheckType selection[1]
						
		if ( skinType == 0 ) do return()
		
		undo on (
		case skinType of
		(
			2:
			(
				selection[1].modifiers[idEditPolyModifier].ButtonOp #UnhideAllFace
				selection[1].modifiers[idEditPolyModifier].ButtonOp #UnhideAllVertex
			)-- 2 end
			
			3:
			(
				selection[1].EditablePoly.unhideAll #Face
				selection[1].EditablePoly.unhideAll #Vertex
			)-- 3 end
			
			default: return ()
		)
		)-- undo end
	)
	
	on uiBtnAbout pressed do
	(
		shellLaunch "http://cafe.naver.com/pinksox/6126" ""
	)
	
	on SoxSkinHideManager open do
	(

	)
	
	on SoxSkinHideManager close do
	(

	)
)

createDialog SoxSkinHideManager style:#(#style_titlebar, #style_toolwindow, #style_sysmenu) lockWidth:true