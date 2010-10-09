{-# LANGUAGE OverloadedStrings #-}
module Text.Digestive.Blaze.Html5 where

import Control.Applicative ((<$>))
import Control.Monad (mplus, forM_, unless, when)
import Data.Maybe (fromMaybe)
import Data.Monoid (mempty)

import Text.Blaze.Html5 (Html, (!))
import qualified Text.Blaze.Html5 as H
import qualified Text.Blaze.Html5.Attributes as A

import Text.Digestive.Types
import qualified Text.Digestive.Common as Common

-- | Checks the input element when the argument is true
--
checked :: Bool -> Html -> Html
checked False x = x
checked True  x = x ! A.checked "checked"

inputString :: (Monad m, Functor m)
            => Maybe String
            -> Form m String e Html String
inputString = Common.inputString $ \id' inp ->
    H.input ! A.type_ "text"
            ! A.name (H.stringValue $ show id')
            ! A.id (H.stringValue $ show id')
            ! A.value (H.stringValue $ fromMaybe "" inp)

inputRead :: (Monad m, Functor m, Show a, Read a)
          => Maybe a
          -> Form m String String Html a
inputRead = flip Common.inputRead "No read" $ \id' inp ->
    H.input ! A.type_ "text"
            ! A.name (H.stringValue $ show id')
            ! A.id (H.stringValue $ show id')
            ! A.value (H.stringValue $ fromMaybe "" inp)

inputPassword :: (Monad m, Functor m)
              => Form m String e Html String
inputPassword = flip Common.inputString Nothing $ \id' inp ->
    H.input ! A.type_ "password"
            ! A.name (H.stringValue $ show id')
            ! A.id (H.stringValue $ show id')
            ! A.value (H.stringValue $ fromMaybe "" inp)

inputBool :: (Monad m, Functor m)
          => Bool
          -> Form m String e Html Bool
inputBool inp = flip Common.inputBool inp $ \id' inp ->
    checked inp $ H.input ! A.type_ "checkbox"
                          ! A.name (H.stringValue $ show id')
                          ! A.id (H.stringValue $ show id')

inputRadio :: (Monad m, Functor m, Eq a)
           => Bool                        -- ^ Use @<br>@ tags
           -> a                           -- ^ Default option
           -> [(a, Html)]                 -- ^ Choices with their names
           -> Form m String e Html a      -- ^ Resulting form
inputRadio br def choices = Common.inputChoice toView def (map fst choices)
  where
    toView group id' sel val = do
        checked sel $ H.input ! A.type_ "radio"
                              ! A.name (H.stringValue $ show group)
                              ! A.value (H.stringValue id')
                              ! A.id (H.stringValue id')
        H.label ! A.for (H.stringValue id')
                $ fromMaybe mempty $ lookup val choices
        when br H.br

label :: Monad m
      => String
      -> Form m i e Html a
label string = Common.label $ \id' ->
    H.label ! A.for (H.stringValue $ show id')
            $ H.string string

errorList :: [String] -> Html
errorList errors = unless (null errors) $
    H.ul $ forM_ errors $ H.li . H.string

errors :: Monad m
       => Form m i String Html a
errors = Common.errors errorList

childErrors :: Monad m
            => Form m i String Html a
childErrors = Common.childErrors errorList