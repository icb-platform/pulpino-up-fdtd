#ifndef _USER_PLUGIN_APB_H_
#define _USER_PLUGIN_APB_H_

#include <pulpino.h>

#define UP_APB_REG_A      ( USER_PLUGIN_APB_BASE_ADDR + 0x00 )
#define UP_APB_REG_B      ( USER_PLUGIN_APB_BASE_ADDR + 0x04 )
#define UP_APB_REG_S      ( USER_PLUGIN_APB_BASE_ADDR + 0x08 )

#define UP_APB_REG_CTRL   ( USER_PLUGIN_APB_BASE_ADDR + 0x0C )
#define UP_APB_REG_CMD    ( USER_PLUGIN_APB_BASE_ADDR + 0x10 )
#define UP_APB_REG_STATUS ( USER_PLUGIN_APB_BASE_ADDR + 0x14 )

#define UP_APB_REG_PADDIR ( USER_PLUGIN_APB_BASE_ADDR + 0x20 )
#define UP_APB_REG_PADIN  ( USER_PLUGIN_APB_BASE_ADDR + 0x24 )
#define UP_APB_REG_PADOUT ( USER_PLUGIN_APB_BASE_ADDR + 0x28 )

#define UP_APB_A          REG(UP_APB_REG_A)
#define UP_APB_B          REG(UP_APB_REG_B)
#define UP_APB_S          REG(UP_APB_REG_S)

#define UP_APB_CTRL       REG(UP_APB_REG_CTRL)
#define UP_APB_CMD        REG(UP_APB_REG_CMD)
#define UP_APB_STATUS     REG(UP_APB_REG_STATUS)

#define UP_APB_PADDIR     REG(UP_APB_REG_PADDIR)
#define UP_APB_PADIN      REG(UP_APB_REG_PADIN)
#define UP_APB_PADOUT     REG(UP_APB_REG_PADOUT)

#define UP_CTRL_INT_EN_BIT (1 << 0)

#define UP_CMD_CLR_INT_BIT (1 << 0)
#define UP_CMD_SET_INT_BIT (1 << 1)

#define UP_STATUS_INT_BIT  (1 << 0)

#endif
