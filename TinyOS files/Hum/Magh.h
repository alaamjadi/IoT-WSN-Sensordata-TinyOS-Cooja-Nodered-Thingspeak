#ifndef MAGH_H
#define MAGH_H

typedef nx_struct magh_msg {
  nx_uint8_t msg_type;
  nx_uint16_t data;
} magh_msg_t;

enum {
  RADIO_MSG = 6,
};

#endif