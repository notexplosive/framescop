local ctlStateEnum = {}
ctlStateEnum.ALL_BUTTONS = {'up','down','left','right','x','circle','triangle','square','start','select'}
ctlStateEnum.DIRECTIONS = {'up','down','left','right'}
ctlStateEnum.FACE_BUTTONS = {'x','circle','triangle','square'}
ctlStateEnum.START_SELECT = {'start','select'}

ctlStateEnum.isKeyFrame = 1
ctlStateEnum.up = 2
ctlStateEnum.down = 4
ctlStateEnum.left = 8
ctlStateEnum.right = 16
ctlStateEnum.confirm = 32
ctlStateEnum.deny = 64
ctlStateEnum.x = 128
ctlStateEnum.circle = 256
ctlStateEnum.triangle = 512
ctlStateEnum.square = 1024
ctlStateEnum.start = 2048
ctlStateEnum.select = 4096
ctlStateEnum.l1 = 8192
ctlStateEnum.l2 = 16384
ctlStateEnum.r1 = 32768
ctlStateEnum.r2 = 65536

function isButton(str)
    return isInList(str,ctlStateEnum.ALL_BUTTONS)
end

function isFaceButton(str)
    return isInList(str,ctlStateEnum.FACE_BUTTONS)
end

function isDirection(str)
    return isInList(str,ctlStateEnum.DIRECTIONS)
end

function isStartSelect(str)
    return isInList(str,ctlStateEnum.START_SELECT)
end


return ctlStateEnum