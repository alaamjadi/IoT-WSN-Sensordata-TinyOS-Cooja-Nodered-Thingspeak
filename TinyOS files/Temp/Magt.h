#ifndef MAGT_H
#define MAGT_H

typedef nx_struct magt_msg {
  nx_uint8_t msg_type;
  nx_uint16_t data;
} magt_msg_t;

enum {
  RADIO_MSG = 6,
};

#endif