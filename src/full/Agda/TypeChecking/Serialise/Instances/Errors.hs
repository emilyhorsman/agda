{-# LANGUAGE RecordWildCards          #-}
{-# LANGUAGE CPP                      #-}
{-# OPTIONS_GHC -fno-warn-orphans     #-}

module Agda.TypeChecking.Serialise.Instances.Errors where

import Data.Maybe

import Control.Monad

import Agda.TypeChecking.Serialise.Base
import Agda.TypeChecking.Serialise.Instances.Common
import Agda.TypeChecking.Serialise.Instances.Internal ()
import Agda.TypeChecking.Serialise.Instances.Abstract ()

import Agda.Syntax.Common
import Agda.Syntax.Concrete.Definitions (DeclarationWarning(..))
import Agda.Syntax.Abstract.Name (ModuleName)
import Agda.TypeChecking.Monad.Base
import Agda.Interaction.Options
import Agda.Interaction.Options.Warnings
import Agda.Interaction.Library
import Agda.Interaction.Library.Parse
import Agda.Termination.CutOff
import Agda.TypeChecking.Positivity.Occurrence ()
import Agda.Syntax.Parser.Monad (ParseWarning( OverlappingTokensWarning ))
import Agda.Utils.Pretty
import Agda.Utils.FileName ()

import Agda.Utils.Lens

#include "undefined.h"
import Agda.Utils.Impossible

instance EmbPrj TCWarning where
  icod_ (TCWarning a b c d) = icodeN' TCWarning a b c d

  value = valueN TCWarning

-- We don't need to serialise warnings that turn into errors
instance EmbPrj Warning where
  icod_ (TerminationIssue a)         = __IMPOSSIBLE__
  icod_ (UnreachableClauses a b)     = icodeN 0 UnreachableClauses a b
  icod_ (CoverageIssue a b)          = __IMPOSSIBLE__
  icod_ (NotStrictlyPositive a b)    = __IMPOSSIBLE__
  icod_ (UnsolvedMetaVariables a)    = __IMPOSSIBLE__
  icod_ (UnsolvedInteractionMetas a) = __IMPOSSIBLE__
  icod_ (UnsolvedConstraints a)      = __IMPOSSIBLE__
  icod_ (OldBuiltin a b)             = icodeN 1 OldBuiltin a b
  icod_ EmptyRewritePragma           = icodeN 2 EmptyRewritePragma
  icod_ UselessPublic                = icodeN 3 UselessPublic
  icod_ (UselessInline a)            = icodeN 4 UselessInline a
  icod_ (GenericWarning a)           = icodeN 5 GenericWarning a
  icod_ (GenericNonFatalError a)     = __IMPOSSIBLE__
  icod_ (SafeFlagPostulate a)        = __IMPOSSIBLE__
  icod_ (SafeFlagPragma a)           = __IMPOSSIBLE__
  icod_ SafeFlagNonTerminating       = __IMPOSSIBLE__
  icod_ SafeFlagTerminating          = __IMPOSSIBLE__
  icod_ SafeFlagWithoutKFlagPrimEraseEquality    = __IMPOSSIBLE__
  icod_ SafeFlagNoPositivityCheck    = __IMPOSSIBLE__
  icod_ SafeFlagPolarity             = __IMPOSSIBLE__
  icod_ SafeFlagNoUniverseCheck      = __IMPOSSIBLE__
  icod_ (ParseWarning a)             = __IMPOSSIBLE__
  icod_ (DeprecationWarning a b c)   = icodeN 6 DeprecationWarning a b c
  icod_ (NicifierIssue a)            = icodeN 7 NicifierIssue a
  icod_ (InversionDepthReached a)    = icodeN 8 InversionDepthReached a
  icod_ (UserWarning a)              = icodeN 9 UserWarning a
  icod_ (AbsurdPatternRequiresNoRHS a) = icodeN 10 AbsurdPatternRequiresNoRHS a
  icod_ (ModuleDoesntExport a b)       = icodeN 11 ModuleDoesntExport a b
  icod_ (LibraryWarning a)           = icodeN 12 LibraryWarning a
  icod_ (CoverageNoExactSplit a b)   = icodeN 13 CoverageNoExactSplit a b
  icod_ (CantGeneralizeOverSorts a)  = icodeN 14 CantGeneralizeOverSorts a
  icod_ IllformedAsClause            = icodeN 15 IllformedAsClause
  icod_ WithoutKFlagPrimEraseEquality = icodeN 16 WithoutKFlagPrimEraseEquality
  icod_ (InstanceWithExplicitArg a)  = icodeN 17 InstanceWithExplicitArg a
  icod_ (InfectiveImport a b)          = icodeN 18 InfectiveImport a b
  icod_ (CoInfectiveImport a b)        = icodeN 19 CoInfectiveImport a b

  value = vcase valu where
      valu [0, a, b]    = valuN UnreachableClauses a b
      valu [1, a, b]    = valuN OldBuiltin a b
      valu [2]          = valuN EmptyRewritePragma
      valu [3]          = valuN UselessPublic
      valu [4, a]       = valuN UselessInline a
      valu [5, a]       = valuN GenericWarning a
      valu [6, a, b, c] = valuN DeprecationWarning a b c
      valu [7, a]       = valuN NicifierIssue a
      valu [8, a]       = valuN InversionDepthReached a
      valu [9, a]       = valuN UserWarning a
      valu [10, a]      = valuN AbsurdPatternRequiresNoRHS a
      valu [11, a, b]   = valuN ModuleDoesntExport a b
      valu [12, a]      = valuN LibraryWarning a
      valu [13, a, b]   = valuN CoverageNoExactSplit a b
      valu [14, a]      = valuN CantGeneralizeOverSorts a
      valu [15]         = valuN IllformedAsClause
      valu [16]         = valuN WithoutKFlagPrimEraseEquality
      valu [17, a]      = valuN InstanceWithExplicitArg a
      valu [18, a, b]   = valuN InfectiveImport a b
      valu [19, a, b]   = valuN InfectiveImport a b
      valu _ = malformed

instance EmbPrj DeclarationWarning where
  icod_ = \case
    UnknownNamesInFixityDecl a        -> icodeN 0 UnknownNamesInFixityDecl a
    UnknownNamesInPolarityPragmas a   -> icodeN 1 UnknownNamesInPolarityPragmas a
    PolarityPragmasButNotPostulates a -> icodeN 2 PolarityPragmasButNotPostulates a
    UselessPrivate a                  -> icodeN 3 UselessPrivate a
    UselessAbstract a                 -> icodeN 4 UselessAbstract a
    UselessInstance a                 -> icodeN 5 UselessInstance a
    EmptyMutual a                     -> icodeN 6 EmptyMutual a
    EmptyAbstract a                   -> icodeN 7 EmptyAbstract a
    EmptyPrivate a                    -> icodeN 8 EmptyPrivate a
    EmptyInstance a                   -> icodeN 9 EmptyInstance a
    EmptyMacro a                      -> icodeN 10 EmptyMacro a
    EmptyPostulate a                  -> icodeN 11 EmptyPostulate a
    InvalidTerminationCheckPragma a   -> icodeN 12 InvalidTerminationCheckPragma a
    InvalidNoPositivityCheckPragma a  -> icodeN 13 InvalidNoPositivityCheckPragma a
    InvalidCatchallPragma a           -> icodeN 14 InvalidCatchallPragma a
    InvalidNoUniverseCheckPragma a    -> icodeN 15 InvalidNoUniverseCheckPragma a
    UnknownFixityInMixfixDecl a       -> icodeN 16 UnknownFixityInMixfixDecl a
    MissingDefinitions a              -> icodeN 17 MissingDefinitions a
    NotAllowedInMutual r a            -> icodeN 18 NotAllowedInMutual r a
    PragmaNoTerminationCheck r        -> icodeN 19 PragmaNoTerminationCheck r
    EmptyGeneralize a                 -> icodeN 20 EmptyGeneralize a
    PragmaCompiled r                  -> icodeN 21 PragmaCompiled r

  value = vcase $ \case
    [0, a]   -> valuN UnknownNamesInFixityDecl a
    [1, a]   -> valuN UnknownNamesInPolarityPragmas a
    [2, a]   -> valuN PolarityPragmasButNotPostulates a
    [3, a]   -> valuN UselessPrivate a
    [4, a]   -> valuN UselessAbstract a
    [5, a]   -> valuN UselessInstance a
    [6, a]   -> valuN EmptyMutual a
    [7, a]   -> valuN EmptyAbstract a
    [8, a]   -> valuN EmptyPrivate a
    [9, a]   -> valuN EmptyInstance a
    [10,a]   -> valuN EmptyMacro a
    [11,a]   -> valuN EmptyPostulate a
    [12,a]   -> valuN InvalidTerminationCheckPragma a
    [13,a]   -> valuN InvalidNoPositivityCheckPragma a
    [14,a]   -> valuN InvalidCatchallPragma a
    [15,a]   -> valuN InvalidNoUniverseCheckPragma a
    [16,a]   -> valuN UnknownFixityInMixfixDecl a
    [17,a]   -> valuN MissingDefinitions a
    [18,r,a] -> valuN NotAllowedInMutual r a
    [19,r]   -> valuN PragmaNoTerminationCheck r
    [20,a]   -> valuN EmptyGeneralize a
    [21,a]   -> valuN PragmaCompiled a
    _ -> malformed

instance EmbPrj LibWarning where
  icod_ = \case
    LibWarning a b -> icodeN 0 LibWarning a b

  value = vcase $ \case
    [0, a, b]   -> valuN LibWarning a b
    _ -> malformed

instance EmbPrj LibWarning' where
  icod_ = \case
    UnknownField a -> icodeN 0 UnknownField a

  value = vcase $ \case
    [0, a]   -> valuN UnknownField a
    _ -> malformed

instance EmbPrj LibPositionInfo where
  icod_ = \case
    LibPositionInfo a b c -> icodeN 0 LibPositionInfo a b c

  value = vcase $ \case
    [0, a, b, c]   -> valuN LibPositionInfo a b c
    _ -> malformed

instance EmbPrj Doc where
  icod_ d = icodeN' (undefined :: String -> Doc) (render d)

  value = valueN text

instance EmbPrj PragmaOptions where
  icod_ = \case
    PragmaOptions a b c d e f g h i j k l m n o p q r s t u v w x y z aa bb cc dd ee ff gg hh ii jj kk ll mm -> icodeN' PragmaOptions a b c d e f g h i j k l m n o p q r s t u v w x y z aa bb cc dd ee ff gg hh ii jj kk ll mm

  value = vcase $ \case
    [a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z, aa, bb, cc, dd, ee, ff, gg, hh, ii, jj, kk, ll, mm]   -> valuN PragmaOptions a b c d e f g h i j k l m n o p q r s t u v w x y z aa bb cc dd ee ff gg hh ii jj kk ll mm
    _ -> malformed

instance EmbPrj WarningMode where
  icod_ = \case
    WarningMode a b -> icodeN' WarningMode a b

  value = vcase $ \case
    [a, b]   -> valuN WarningMode a b
    _ -> malformed

instance EmbPrj WarningName where
  icod_ x = icod_ (warningName2String x)

  value = (maybe malformed return . string2WarningName) <=< value


instance EmbPrj CutOff where
  icod_ = \case
    DontCutOff -> icodeN' DontCutOff
    CutOff a -> icodeN 0 CutOff a

  value = vcase valu where
    valu [] = valuN DontCutOff
    valu [0,a] = valuN CutOff a
    valu _ = malformed
