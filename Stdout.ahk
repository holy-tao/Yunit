class YunitStdOut
{
    __new(instance)
    {
    }

    Update(Category, Test, Result, Time) ;wip: this only supports one level of nesting?
    {
        if Result is Error
        {
            Details := " at line " Result.Line " " Result.Message "(" Result.File ")"
            Status := "FAIL"
        }
        else
        {
            Details := ""
            Status := "PASS"
        }
        FileAppend(Format("{1}: {2} {3} {4} ({5} ms)`n", Status, Category, Test, Details, Time * 1000), "*")
    }
}
