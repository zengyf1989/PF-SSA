#ifndef PF-SSAAPP_H
#define PF-SSAAPP_H

#include "MooseApp.h"

class Pf-SsaApp;

template<>
InputParameters validParams<Pf-SsaApp>();

class Pf-SsaApp : public MooseApp
{
public:
  Pf-SsaApp(InputParameters parameters);
  virtual ~Pf-SsaApp();

  static void registerApps();
  static void registerObjects(Factory & factory);
  static void associateSyntax(Syntax & syntax, ActionFactory & action_factory);
};

#endif /* PF-SSAAPP_H */
