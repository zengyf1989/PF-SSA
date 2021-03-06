#include "Pf-SsaApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

template<>
InputParameters validParams<Pf-SsaApp>()
{
  InputParameters params = validParams<MooseApp>();

  params.set<bool>("use_legacy_uo_initialization") = false;
  params.set<bool>("use_legacy_uo_aux_computation") = false;
  params.set<bool>("use_legacy_output_syntax") = false;

  return params;
}

Pf-SsaApp::Pf-SsaApp(InputParameters parameters) :
    MooseApp(parameters)
{
  Moose::registerObjects(_factory);
  ModulesApp::registerObjects(_factory);
  Pf-SsaApp::registerObjects(_factory);

  Moose::associateSyntax(_syntax, _action_factory);
  ModulesApp::associateSyntax(_syntax, _action_factory);
  Pf-SsaApp::associateSyntax(_syntax, _action_factory);
}

Pf-SsaApp::~Pf-SsaApp()
{
}

// External entry point for dynamic application loading
extern "C" void Pf-SsaApp__registerApps() { Pf-SsaApp::registerApps(); }
void
Pf-SsaApp::registerApps()
{
  registerApp(Pf-SsaApp);
}

// External entry point for dynamic object registration
extern "C" void Pf-SsaApp__registerObjects(Factory & factory) { Pf-SsaApp::registerObjects(factory); }
void
Pf-SsaApp::registerObjects(Factory & factory)
{
}

// External entry point for dynamic syntax association
extern "C" void Pf-SsaApp__associateSyntax(Syntax & syntax, ActionFactory & action_factory) { Pf-SsaApp::associateSyntax(syntax, action_factory); }
void
Pf-SsaApp::associateSyntax(Syntax & /*syntax*/, ActionFactory & /*action_factory*/)
{
}
