#Requires AutoHotkey v2.0

class YUnitJUnit {

    __new(instance)
    {
        this.filename := A_ScriptDir . "\junit.xml"

        ; the file is deleted if it exists already
        if FileExist(this.filename) {
            FileDelete(this.filename)
        }

        this.out := Array()
        this.tests := {}
        this.tests.pass := 0
        this.tests.fail := 0
        this.tests.overall := 0
		
        Return this
    }
  
    __Delete() {
        file := FileOpen(this.filename, "w")
        file.write('<?xml version="1.0" encoding="UTF-8"?>`n')
        msg := Format('<testsuites failures="{1}" tests="{2}">', this.tests.fail, this.tests.overall)
        file.write(msg . "`n")
        msg := Format('`t<testsuite failures="{1}" tests="{2}" name="{3}">', this.tests.fail, this.tests.overall, "Unit Tests")
        file.write(msg . "`n")

        Loop this.out.Length
            file.write(this.out[A_Index] . "`n")

        file.write("`t</testsuite>`n")
        file.write("</testsuites>`n")
        file.close()
    }
    
    Update(Category, TestName, Result)
    {		
        this.tests.overall := this.tests.overall + 1
        msg := Format('`t`t<testcase name="{1}" classname="{2}"', TestName, Category)
        if Result is Error
        {
            this.out.Push(msg . ">")
            this.tests.fail := this.tests.fail + 1

            this.out.Push(Format('`t`t`t<failure type ="failure" file="{1}" line="{2}">', this.StripPathToRelative(Result.file), Result.Line))
            this.out.Push(this.FormatErrorForReport(Result))
            this.out.Push("`t`t`t</failure>")

            this.out.Push("`t`t</testcase>")
        }
		Else 
        {
            this.out.Push(msg . "/>")
            this.tests.pass := this.tests.pass + 1
        }
    }

    /**
     * Formats an error message for printing
     * @param {Error} err the error to format 
     */
    FormatErrorForReport(err){
        str := Format("{1}: {2}", Type(err), err.message)
        if(err.extra != "")
            str .= Format("`n`tSpecifically: {1}", err.extra)
        str .= "`n`n" . err.stack

        return this.XmlEscape(str)
    }

    /**
     * Escape a string for XML
     * @param {String} str string to escape 
     */
    XmlEscape(str){
        str := StrReplace(str, "&", "&amp;")
        str := StrReplace(str, "<", "&lt;")
        str := StrReplace(str, ">", "&gt;")
        str := StrReplace(str, "'", "&apos;")
        str := StrReplace(str, '"', "&quot;")

        return str
    }

    /**
     * Take an absolute path to a file and strip it so that it's relative to the repo root,
     * for runner annotations
     * @param filepath 
     */
    StripPathToRelative(filepath){
        static repoRoot := StrReplace(YUnitJUnit.Cmd("git rev-parse --show-toplevel"), "/", "\")

        return LTrim(StrReplace(filepath, repoRoot, ""), "\")
    }

    /**
     * Run a command and return its output
     * @param cmd 
     */
    static Cmd(cmd){
        tmpFile := A_ScriptDir . "\.tmp"
        RunWait(Format('{1} /c "{3} 1>{2}"', A_ComSpec, tmpFile, cmd), , "Hide")

        output := Trim(FileRead(tmpFile), "`t`r`n ")
        FileDelete(tmpFile)

        return output
    }
}