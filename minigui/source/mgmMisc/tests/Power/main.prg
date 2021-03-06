#include <hmg.ch>

PROCEDURE Main()
   LOCAL aFormColor := {31,37,61}
   LOCAL HeaderBackColor := {  52, 104, 175 }
   LOCAL HeaderFontColor := { 255, 255, 255 }
   LOCAL smallFontSize   := 10
   LOCAL mainFontSize    := 12
   LOCAL mainFont        := 'Verdana'

/*
   LOCAL cMemo := hb_MemoRead( "uni.txt" )
   
   msgInfo( cMemo )
   msginfo( iif( IsTextUnicode( @cMemo ), "Unicode text!", "Don't know! (probably ansi) text1" ) )
*/   
   
   LOAD WINDOW MainFrm
   SET CENTERWINDOW RELATIVE PARENT
   CENTER WINDOW MainFrm
   ACTIVATE WINDOW MainFrm

RETURN

#define HTCAPTION          2
#define WM_NCLBUTTONDOWN   161
PROCEDURE MoveActiveWindow( hWnd, cForm )

   LOCAL nMouseRow := GetCursorRow()
   LOCAL nFormRow := GetProperty(cForm,'Row')

   hb_Default( @hWnd, GetActiveWindow() )
   IF (nMouseRow >= nFormRow) .AND. (nMouseRow <= (nFormRow + 45))
     PostMessage( hWnd, WM_NCLBUTTONDOWN, HTCAPTION, 0 )
   ENDIF

PROCEDURE MsgAbout()
   MsgInfo( '�Ask, and it shall be given you; seek, and ye shall find; '+ hb_eol()+;
            '�knock, and it shall be opened unto you:'+ hb_eol()+;
            '�For every one that asketh receiveth; and he that seeketh findeth; '+hb_eol()+;
            '�and to him that knocketh it shall be opened.�',;
            "About.." )
RETURN

PROCEDURE ChkUni()

   IF IsWindowUnicode( GetActiveWindow() )
      MsgInfo( "Unicode!" )
   ELSE
      MsgInfo( "Ansi!" )
   ENDIF
   RETURN
   
      
   
#pragma begindump
#include <mgdefs.h>
#include <winbase.h>
HB_FUNC( ISWINDOWUNICODE )
{
   hb_retl( IsWindowUnicode( (HWND) hb_parnl( 1 ) ) );
}

HB_FUNC( ISTEXTUNICODE )
{
   const char * buff = hb_parcx( 1 );
   HB_SIZE iSize = hb_parcsiz( 1 );
   LPINT lpiResult = NULL ; // 0x0001 ; // IS_TEXT_UNICODE_SIGNATURE; // IS_TEXT_UNICODE_ASCII16|IS_TEXT_UNICODE_STATISTICS;
   
   hb_retl( IsTextUnicode( buff, iSize, lpiResult ) );
   /*
   MessageBox( 0, buff, "is1", 1 ); 
   itoa(iSize, buff, 10);
   MessageBox( 0, buff, "is2", 1 ); 
   */
   
}

#pragma enddump



