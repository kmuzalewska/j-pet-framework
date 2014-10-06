#ifndef _JPETTRB_H_
#define _JPETTRB_H_

#include "TNamed.h"
#include <TRef.h>
#include "../JPetTOMB/JPetTOMB.h"

/**
 * @brief Parametric class representing database information on parameters of a TRB board.
 *
 */
class JPetTRB: public TNamed
{
 public:
  JPetTRB();
  JPetTRB(int id, int type, int channel);
  inline int getID() const { return fID; }
  inline int getType() const { return fType; }
  inline int getChannel() const { return fChannel; }
  inline void setID(int id) { fID = id; }
  inline void setType(int type) { fType = type; }
  inline void setChannel(int ch) { fChannel = ch; }

  JPetTOMB* getTRefTOMB() { return (JPetTOMB*)fTRefTOMB.GetObject(); }
  void setTRefTOMB(JPetTOMB &p_TOMB)
  {
    fTRefTOMB = &p_TOMB;
  }
  void setTRefTOMB(JPetTOMB* pTOMB)
  {
    fTRefTOMB = pTOMB;
  }
  
 private:
  int fID;
  int fType;
  int fChannel;
  /// @todo do implementacji
  //JPetFEB* KBId;
  //KBType;
  //KBChan;
  //
  ClassDef(JPetTRB, 1);
  
protected:
  TRef fTRefTOMB;
  
  void clearTRefTOMB()
  {
    fTRefTOMB = NULL;
  }
  
  friend class JPetParamManager;
};

#endif
