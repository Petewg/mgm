/*
 * MyUnzip utility
 *
 * Copyright 2008 Mindaugas Kavaliauskas <dbtopas.at.dbtopas.lt>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; see the file LICENSE.txt.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA (or visit https://www.gnu.org/licenses/).
 *
 * As a special exception, the Harbour Project gives permission for
 * additional uses of the text contained in its release of Harbour.
 *
 * The exception is that, if you link the Harbour libraries with other
 * files to produce an executable, this does not by itself cause the
 * resulting executable to be covered by the GNU General Public License.
 * Your use of that executable is in no way restricted on account of
 * linking the Harbour library code into it.
 *
 * This exception does not however invalidate any other reasons why
 * the executable file might be covered by the GNU General Public License.
 *
 * This exception applies only to the code released by the Harbour
 * Project under the name Harbour.  If you copy code from other
 * Harbour Project or Free Software Foundation releases into a copy of
 * Harbour, as the General Public License permits, the exception does
 * not apply to the code that you add in this way.  To avoid misleading
 * anyone as to the status of such modified files, you must delete
 * this exception notice from them.
 *
 * If you write modifications of your own for Harbour, it is your choice
 * whether to permit this exception to apply to your modifications.
 * If you do not wish that, delete this exception notice.
 *
 */

#require "hbmzip"

#include "simpleio.ch"

REQUEST HB_CODEPAGE_UTF8EX

PROCEDURE Main()

   LOCAL hUnzip, aWild, cFileName, cFile
   LOCAL tDate, cTime, nSize, nCompSize, nErr
   LOCAL lCrypted, cPassword, cComment, tmp

   hb_cdpSelect( "UTF8EX" )
   hb_SetTermCP( hb_cdpTerm() )
   Set( _SET_OSCODEPAGE, hb_cdpOS() )

   Set( _SET_DATEFORMAT, "yyyy-mm-dd" )

   aWild := hb_AParams()
   IF Len( aWild ) < 1
      ? "Usage: myunzip <ZipName> [ --pass <password> ] [ <FilePattern1> ... ]"
      RETURN
   ENDIF

   cFileName := hb_FNameExtSetDef( aWild[ 1 ], ".zip" )
   hb_ADel( aWild, 1, .T. )

   FOR tmp := 1 TO Len( aWild ) - 1
      IF Lower( aWild[ tmp ] ) == "--pass"
         cPassword := aWild[ tmp + 1 ]
         aWild[ tmp ] := ""
         aWild[ tmp + 1 ] := ""
      ENDIF
   NEXT

   AEval( aWild, {| cPattern, nPos | aWild[ nPos ] := StrTran( cPattern, "\", "/" ) } )

   IF ! Empty( hUnzip := hb_unzipOpen( cFileName ) )
      ? "Archive file:", cFileName
      hb_unzipGlobalInfo( hUnzip, @nSize, @cComment )
      ? "Number of entries:", hb_ntos( nSize )
      IF ! cComment == ""
         ? "global comment:", cComment
      ENDIF
      ?
      ? "Filename                          Date      Time         Size Compressed  Action"
      ? "-----------------------------------------------------------------------------------"
      nErr := hb_unzipFileFirst( hUnzip )
      DO WHILE nErr == 0
         hb_unzipFileInfo( hUnzip, @cFile, @tDate, @cTime, , , , @nSize, @nCompSize, @lCrypted, @cComment )
         ? hb_UPadR( cFile + iif( lCrypted, "*", "" ), 30 ), hb_TToD( tDate ), cTime, nSize, nCompSize
         IF ! cComment == ""
            ? "comment:", cComment
         ENDIF

         DO CASE
         CASE hb_LeftEq( cFile, "from_memory" )
            hb_unzipExtractCurrentFileToMem( hUnzip, cPassword, @tmp )
            ?? " " + hb_ValToExp( iif( hb_BLen( tmp ) > 60, hb_BLen( tmp ), tmp ) )
         CASE AScan( aWild, {| cPattern | hb_WildMatch( cPattern, cFile, .T. ) } ) > 0
            ?? " " + "Extracting"
            hb_unzipExtractCurrentFile( hUnzip, , cPassword )
         OTHERWISE
            ?? " " + "Skipping"
         ENDCASE

         nErr := hb_unzipFileNext( hUnzip )
      ENDDO
      hb_unzipClose( hUnzip )
   ENDIF

   RETURN
